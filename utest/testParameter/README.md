# testParameter

Unit tests of the `ch3obj/XParameter` classes (`Parameter`, `ScalarParameter`,
`VectorParameter`, `TensorParameter`, `FreeParameter`), inspired by the
examples in `tutorial/parameter`.

## Contents
- `TestParameter.m` — `matlab.unittest` test class : construction and
  dependency-token parsing, free parameters, `varargin_list`, mesh/time/field
  dependencies (same model, same mesh with same/different `ltime`,
  cross-mesh time+space interpolation), serial vs vectorized evaluation,
  and the subclasses (constant validation, `get_inverse`).
- `run_create_test_models.m` — builds and saves the sample models
  (`sample_models_testParameter.mat`, gitignored, regenerated on first run).
- `f__affine.m` — helper function with name-value options, used to test
  `varargin_list`.
- `Parameter.m` — **refactored proposal** for `ch3obj/XParameter/Parameter.m`
  (branch `49-core-dev-reorg-07-26`), see below.

## Run
```matlab
% champ3d folders on the MATLAB path, then :
addpath('utest/testParameter');
results = runtests('TestParameter');
table(results)
```
The first run solves three small thermal models to create the `.mat` fixture
(a few seconds) ; subsequent runs reuse it. Delete the `.mat` file to force
regeneration.

## ⚠️ Parameter.m shadowing (A/B testing)
This folder contains the refactored `Parameter.m`. Since `addpath` puts the
folder **ahead** of `ch3obj/XParameter` on the path, the tests run against
the **refactored** version (the subclasses inherit from it too).

- To test the **original** version instead : move `Parameter.m` out of this
  folder (or rename it with a non-`.m` extension), then `clear classes` and
  rerun.
- Always run `clear classes` when switching between the two versions.
- Once the refactored version is validated, replace
  `ch3obj/XParameter/Parameter.m` with this file and delete it from here, so
  that the tests target the official version again.
