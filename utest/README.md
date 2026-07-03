# Unit test

Class-based `matlab.unittest` tests, one folder per tested feature.

## Run
```matlab
% champ3d folders on the MATLAB path, then e.g. :
addpath('utest/testParameter');
results = runtests('TestParameter');
```

## Folders
- `testParameter/` — tests of the `ch3obj/XParameter` classes (see its README).

`.mat` test fixtures are gitignored : each folder regenerates them locally
with its `run_create_...` function on first run.
