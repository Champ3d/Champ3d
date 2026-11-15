#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "f_qmr.h"

/* Below these sizes, parallel regions run with the `if()` clause false
 * (pure serial execution, zero fork/join overhead). Tune to taste; the
 * right value depends on core count and memory bandwidth. */
#ifndef F_QMR_MIN_N
#define F_QMR_MIN_N 512
#endif
#ifndef F_QMR_MIN_NNZ
#define F_QMR_MIN_NNZ 4096
#endif

/* ------------------------------------------------------------------ */
/* Sparse (CSC) complex helpers                                       */
/* ------------------------------------------------------------------ */

/* Binary search column `col` for row `row`; sorted row indices assumed
 * (guaranteed by MATLAB's sparse storage). */
static int find_entry(const size_t *Jc, const size_t *Ir, const double complex *Val,
                       size_t col, size_t row, double complex *out)
{
    size_t lo = Jc[col], hi = Jc[col + 1];
    while (lo < hi) {
        size_t mid = lo + (hi - lo) / 2;
        size_t r = Ir[mid];
        if (r == row) { *out = Val[mid]; return 1; }
        else if (r < row) lo = mid + 1;
        else hi = mid;
    }
    return 0;
}

/*
 * y = A*x, or y = A'*x == conj(A)*x when A.' = A (conjugate = 1).
 *
 * Computed as a per-column GATHER rather than the usual scatter:
 * column j's stored entries (i, A_ij) satisfy, by symmetry,
 *   sum_i A_ij * x_i = sum_i (A^T)_ji * x_i = (A^T x)_j = (A x)_j.
 * So y[j] is a self-contained reduction over column j only -- every
 * thread owns disjoint output indices, so this parallelizes with a
 * plain "parallel for" and no atomics/reductions/transposed structure.
 */
static void spmatvec(int n, const size_t *Jc, const size_t *Ir, const double complex *Val,
                      const double complex *x, double complex *y, int conjugate)
{
    size_t nnz = Jc[n];
    #pragma omp parallel for schedule(dynamic, 64) if(nnz > F_QMR_MIN_NNZ)
    for (int j = 0; j < n; j++) {
        double complex s = 0.0;
        size_t k0 = Jc[j], k1 = Jc[j + 1];
        if (conjugate) {
            for (size_t k = k0; k < k1; k++) s += conj(Val[k]) * x[Ir[k]];
        } else {
            for (size_t k = k0; k < k1; k++) s += Val[k] * x[Ir[k]];
        }
        y[j] = s;
    }
}

/* Euclidean norm of a complex vector, matches MATLAB norm(v) */
static double cvec_norm(int n, const double complex *v)
{
    double s = 0.0;
    #pragma omp parallel for reduction(+:s) schedule(static) if(n > F_QMR_MIN_N)
    for (int i = 0; i < n; i++) s += creal(v[i]) * creal(v[i]) + cimag(v[i]) * cimag(v[i]);
    return sqrt(s);
}

/* Hermitian inner product z'*y = sum conj(z_i)*y_i, matches MATLAB z'*y.
 * Accumulated as two real reductions (real/imag parts) for portability:
 * not every OpenMP/C compiler combination supports a reduction directly
 * over _Complex double. */
static double complex cvec_dot(int n, const double complex *z, const double complex *y)
{
    double sre = 0.0, sim = 0.0;
    #pragma omp parallel for reduction(+:sre,sim) schedule(static) if(n > F_QMR_MIN_N)
    for (int i = 0; i < n; i++) {
        double complex t = conj(z[i]) * y[i];
        sre += creal(t);
        sim += cimag(t);
    }
    return sre + sim * I;
}

static int cis_zero(double complex v) { return creal(v) == 0.0 && cimag(v) == 0.0; }

/* ------------------------------------------------------------------ */
/* QMR, sparse complex-symmetric A, Jacobi preconditioner, OpenMP       */
/*                                                                     */
/* For a diagonal M, [M1,M2] = lu(M) reduces to M1 = I, M2 = diag(d)   */
/* (no pivoting needed), so every M1/M2 solve is a plain elementwise   */
/* operation. On top of that, M1 = I makes the "y" sequence in the     */
/* reference algorithm (y = M1\v_tld) identically equal to v_tld/v at  */
/* every point it's used, and M1' = I makes z_tld identically equal to */
/* z -- both arrays (and their update loops) are eliminated below,     */
/* using v/v_tld and z directly instead. This is a pure algebraic      */
/* simplification (verified against qmr_ser/qmr_reference), not an     */
/* approximation.                                                      */
/* ------------------------------------------------------------------ */

int f_qmr_solve(int n,
              const size_t *Jc, const size_t *Ir, const double complex *Val,
              double complex *x,
              const double complex *b,
              int max_it,
              double tol,
              double *out_error,
              int *out_iter,
              double *resvec)
{
    int flag = 0;
    int iter = 0;
    double error = 0.0;

    double complex *d = NULL; /* Jacobi preconditioner: diag(A) */
    double complex *r = NULL, *v_tld = NULL, *w_tld = NULL, *z = NULL;
    double complex *v = NULL, *w = NULL, *y_tld = NULL;
    double complex *p = NULL, *q = NULL, *p_tld = NULL, *s_vec = NULL, *dd = NULL;

    double bnrm2 = cvec_norm(n, b);
    if (bnrm2 == 0.0) bnrm2 = 1.0;

    d = malloc((size_t)n * sizeof(double complex));
    r = malloc((size_t)n * sizeof(double complex));
    v_tld = malloc((size_t)n * sizeof(double complex));
    w_tld = malloc((size_t)n * sizeof(double complex));
    z = malloc((size_t)n * sizeof(double complex));
    v = malloc((size_t)n * sizeof(double complex));
    w = malloc((size_t)n * sizeof(double complex));
    y_tld = malloc((size_t)n * sizeof(double complex));
    p = malloc((size_t)n * sizeof(double complex));
    q = malloc((size_t)n * sizeof(double complex));
    p_tld = malloc((size_t)n * sizeof(double complex));
    dd = malloc((size_t)n * sizeof(double complex));   /* "d" in qmr.m (correction vector) */
    s_vec = malloc((size_t)n * sizeof(double complex));

    if (!d || !r || !v_tld || !w_tld || !z || !v || !w ||
        !y_tld || !p || !q || !p_tld || !dd || !s_vec) {
        flag = -8;
        goto cleanup;
    }

    #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
    for (int j = 0; j < n; j++) {
        double complex dv = 0.0;
        find_entry(Jc, Ir, Val, (size_t)j, (size_t)j, &dv); /* caller guarantees dv != 0 */
        d[j] = dv;
    }

    /* r = b - A*x; error = norm(r)/bnrm2 */
    spmatvec(n, Jc, Ir, Val, x, r, 0);
    #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
    for (int i = 0; i < n; i++) r[i] = b[i] - r[i];
    error = cvec_norm(n, r) / bnrm2;
    if (resvec) resvec[0] = error * bnrm2;
    if (error < tol) {
        iter = 0;
        goto cleanup;
    }

    double rho, xi;
    double complex gamma, eta, theta;
    double complex delta = 0.0, ep = 0.0, beta = 0.0;
    double complex rho_1, gamma_1, theta_1;

    memcpy(v_tld, r, (size_t)n * sizeof(double complex));
    rho = cvec_norm(n, v_tld); /* y = M1\v_tld = v_tld (M1 = I) */

    memcpy(w_tld, r, (size_t)n * sizeof(double complex));
    #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
    for (int i = 0; i < n; i++) z[i] = w_tld[i] / conj(d[i]); /* z = M2'\ w_tld */
    xi = cvec_norm(n, z);

    gamma = 1.0;
    eta = -1.0;
    theta = 0.0;

    for (iter = 1; iter <= max_it; iter++) {
        if (rho == 0.0 || xi == 0.0) { flag = (rho == 0.0) ? -1 : -6; break; }

        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) v[i] = v_tld[i] / rho; /* also y = M1\v_tld, y == v (M1 = I) */
        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) { w[i] = w_tld[i] / xi; z[i] = z[i] / xi; }

        delta = cvec_dot(n, z, v); /* z'*y, y == v */
        if (cis_zero(delta)) { flag = -4; break; }

        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) y_tld[i] = v[i] / d[i]; /* y_tld = M2\y, y == v */
        /* z_tld = M1'\z == z (M1' = I): use z directly below */

        if (iter > 1) {
            double complex coef_p = xi * delta / ep;
            double complex coef_q = rho * delta / ep;
            #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
            for (int i = 0; i < n; i++) {
                p[i] = y_tld[i] - coef_p * p[i];
                q[i] = z[i] - coef_q * q[i];
            }
        } else {
            #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
            for (int i = 0; i < n; i++) { p[i] = y_tld[i]; q[i] = z[i]; }
        }

        spmatvec(n, Jc, Ir, Val, p, p_tld, 0); /* p_tld = A*p */
        ep = cvec_dot(n, q, p_tld); /* q'*p_tld */
        if (cis_zero(ep)) { flag = -5; break; }

        beta = ep / delta;
        if (cis_zero(beta)) { flag = -2; break; }

        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) v_tld[i] = p_tld[i] - beta * v[i]; /* y = M1\v_tld == v_tld */

        rho_1 = rho;
        rho = cvec_norm(n, v_tld);

        spmatvec(n, Jc, Ir, Val, q, w_tld, 1); /* w_tld = A'*q = conj(A)*q */
        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) w_tld[i] -= beta * w[i];
        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) z[i] = w_tld[i] / conj(d[i]); /* z = M2'\ w_tld */

        xi = cvec_norm(n, z);

        gamma_1 = gamma;
        theta_1 = theta;

        theta = rho / (gamma_1 * beta);
        gamma = 1.0 / csqrt(1.0 + theta * theta);
        if (cis_zero(gamma)) { flag = -3; break; }

        eta = -eta * rho_1 * (gamma * gamma) / (beta * (gamma_1 * gamma_1));

        double complex coef_ds = (theta_1 * gamma) * (theta_1 * gamma);
        if (iter > 1) {
            #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
            for (int i = 0; i < n; i++) {
                dd[i] = eta * p[i] + coef_ds * dd[i];
                s_vec[i] = eta * p_tld[i] + coef_ds * s_vec[i];
            }
        } else {
            #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
            for (int i = 0; i < n; i++) { dd[i] = eta * p[i]; s_vec[i] = eta * p_tld[i]; }
        }

        #pragma omp parallel for schedule(static) if(n > F_QMR_MIN_N)
        for (int i = 0; i < n; i++) { x[i] = x[i] + dd[i]; r[i] = r[i] - s_vec[i]; }

        error = cvec_norm(n, r) / bnrm2;
        if (resvec) resvec[iter] = error * bnrm2;
        if (error <= tol) break;
    }
    if (iter > max_it) iter = max_it;

    if (error <= tol) {
        flag = 0;
    } else if (flag == 0) {
        flag = 1; /* no convergence within max_it, and no breakdown occurred */
    }

cleanup:
    free(d);
    free(r); free(v_tld); free(w_tld); free(z);
    free(v); free(w); free(y_tld);
    free(p); free(q); free(p_tld); free(dd); free(s_vec);

    *out_error = error;
    *out_iter = iter;
    return flag;
}
