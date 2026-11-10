#ifndef F_QMR_H
#define F_QMR_H

#include <complex.h>
#include <stddef.h>

/*
 * OpenMP-parallel QMR for sparse, complex-symmetric linear systems
 * (A.' == A, not Hermitian), with a Jacobi (diagonal) preconditioner
 * M = diag(diag(A)), computed internally. Numerically identical
 * algorithm to qmr_ser (see qmr_ser.h) -- only the per-iteration kernels
 * are parallelized. Same caller preconditions: A is symmetric with a
 * nonzero diagonal; not re-checked here.
 *
 * A is supplied in compressed sparse column (CSC) format, matching
 * MATLAB's native sparse storage (see qmr_ser.h for the exact layout).
 *
 * Parallelization strategy (see f_qmr.c for details):
 *   - The sparse matvec is rewritten from the usual scatter form to a
 *     per-column GATHER: because A.' == A, (A*x)[j] equals the dot
 *     product of column j's stored entries with x, so every thread
 *     writes to a disjoint y[j] -- no atomics, no reductions, no
 *     transposed structure, and it computes both A*p and A'*q (via
 *     conj(A)*q) from the very same arrays.
 *   - Norms/dot products use OpenMP reductions.
 *   - Elementwise vector updates are parallel loops.
 *   - All parallel regions carry an `if(size > threshold)` clause so
 *     small problems run single-threaded with no fork/join overhead
 *     (thresholds are compile-time tunable, see top of f_qmr.c).
 *
 * flag on return: identical convention to qmr_ser (0 converged, 1 no
 * convergence, -1..-6 breakdown, -8 out of memory).
 */
int f_qmr_solve(int n,
              const size_t *Jc, const size_t *Ir, const double complex *Val,
              double complex *x,        /* in: initial guess, out: solution */
              const double complex *b,
              int max_it,
              double tol,
              double *out_error,
              int *out_iter,
              double *resvec);          /* NULL, or room for max_it+1 doubles:
                                           resvec[0..iter] = norm(r) history */

#endif /* F_QMR_H */
