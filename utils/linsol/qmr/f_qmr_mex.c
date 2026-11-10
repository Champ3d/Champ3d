/*
 * MEX gateway for f_qmr_solve (see f_qmr.c / f_qmr.h).
 *
 * MATLAB usage:
 *   [x, flag, relres, iter, resvec] = f_qmr(A, b, tol, maxit, M1, M2, x0)
 *
 * Same argument/output order as MATLAB's native qmr. tol defaults to
 * 1e-6, maxit to min(n,20), x0 ([] or omitted) to zeros. M1 and M2 are
 * accepted for compatibility but IGNORED: the Jacobi preconditioner
 * diag(diag(A)) is always used. Outputs: [x, flag, relres, iter, resvec], each optional
 * (resvec(1) = norm(b-A*x0), then one residual norm per iteration).
 *
 * Same semantics, semantics and caller preconditions as qmr_ser (A must
 * be sparse, complex-symmetric with a nonzero diagonal -- not checked
 * here). f_qmr is the OpenMP-parallel version of the same algorithm;
 * results match qmr_ser bit-for-bit-ish (same operation order per
 * thread reduction, floating point sums may differ in the last ULPs
 * across thread counts).
 *
 * Build (from MATLAB, in this folder): run compile_f_qmr.m.
 */

#include <stdlib.h>
#include <complex.h>
#include "mex.h"
#include "f_qmr.h"

static double complex *read_complex(const mxArray *arr, mwSize n)
{
    double complex *out = mxMalloc(n * sizeof(double complex));
    double *pr = mxGetPr(arr);
    double *pi = mxIsComplex(arr) ? mxGetPi(arr) : NULL;
    for (mwSize i = 0; i < n; i++) {
        out[i] = pr[i] + (pi ? pi[i] : 0.0) * I;
    }
    return out;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 2 || nrhs > 7) {
        mexErrMsgIdAndTxt("f_qmr:nrhs", "Usage: [x, flag, relres, iter] = f_qmr(A, b, tol, maxit, M1, M2, x0)");
    }

    const mxArray *A_in = prhs[0];
    const mxArray *b_in = prhs[1];
    const mxArray *x0_in = (nrhs >= 7) ? prhs[6] : NULL;

    mwSize n = mxGetM(A_in);
    if (mxGetN(A_in) != n) mexErrMsgIdAndTxt("f_qmr:A", "A must be square.");
    if (!mxIsSparse(A_in)) mexErrMsgIdAndTxt("f_qmr:sparse", "A must be sparse; pass sparse(A).");
    if (mxGetM(b_in) * mxGetN(b_in) != n) mexErrMsgIdAndTxt("f_qmr:b", "b must have length n.");
    int x0_empty = (x0_in == NULL) || mxIsEmpty(x0_in); /* [] means zero initial guess */
    if (!x0_empty && mxGetM(x0_in) * mxGetN(x0_in) != n) mexErrMsgIdAndTxt("f_qmr:x0", "x0 must be empty or have length n.");

    mwIndex *Jc_mx = mxGetJc(A_in);
    mwIndex *Ir_mx = mxGetIr(A_in);
    size_t nnz = (size_t)Jc_mx[n];

    size_t *Jc = mxMalloc(((size_t)n + 1) * sizeof(size_t));
    size_t *Ir = mxMalloc(nnz * sizeof(size_t));
    for (mwSize i = 0; i <= n; i++) Jc[i] = (size_t)Jc_mx[i];
    for (size_t k = 0; k < nnz; k++) Ir[k] = (size_t)Ir_mx[k];

    double tol = 1e-6;
    int max_it = (n < 20) ? (int)n : 20;
    if (nrhs >= 3 && !mxIsEmpty(prhs[2])) tol = mxGetScalar(prhs[2]);
    if (nrhs >= 4 && !mxIsEmpty(prhs[3])) max_it = (int)mxGetScalar(prhs[3]);

    int is_complex = mxIsComplex(A_in) || mxIsComplex(b_in) || (!x0_empty && mxIsComplex(x0_in));

    double complex *Val = read_complex(A_in, (mwSize)nnz);
    double complex *b = read_complex(b_in, n);
    double complex *x;
    if (x0_empty) {
        x = mxCalloc(n, sizeof(double complex));
    } else {
        x = read_complex(x0_in, n);
    }

    double error;
    int iter;
    double *resvec = (nlhs >= 5) ? mxCalloc((size_t)max_it + 1, sizeof(double)) : NULL;
    int flag = f_qmr_solve((int)n, Jc, Ir, Val, x, b, max_it, tol, &error, &iter, resvec);

    if (nlhs >= 1) {
        mxArray *x_out = mxCreateDoubleMatrix(n, 1, is_complex ? mxCOMPLEX : mxREAL);
        double *xr = mxGetPr(x_out);
        double *xi = is_complex ? mxGetPi(x_out) : NULL;
        for (mwSize i = 0; i < n; i++) {
            xr[i] = creal(x[i]);
            if (xi) xi[i] = cimag(x[i]);
        }
        plhs[0] = x_out;
    }
    if (nlhs >= 2) plhs[1] = mxCreateDoubleScalar((double)flag);
    if (nlhs >= 3) plhs[2] = mxCreateDoubleScalar(error);
    if (nlhs >= 4) plhs[3] = mxCreateDoubleScalar((double)iter);

    if (nlhs >= 5) {
        /* resvec(1) = norm(b-A*x0), then one entry per completed iteration */
        mwSize len = (mwSize)iter + ((flag == 0 || flag == 1) ? 1 : 0); /* breakdown at iter: no entry for it */
        if (len == 0) len = 1;
        mxArray *rv = mxCreateDoubleMatrix(len, 1, mxREAL);
        for (mwSize i = 0; i < len; i++) mxGetPr(rv)[i] = resvec[i];
        plhs[4] = rv;
        mxFree(resvec);
    }

    mxFree(Jc); mxFree(Ir); mxFree(Val); mxFree(b); mxFree(x);
}
