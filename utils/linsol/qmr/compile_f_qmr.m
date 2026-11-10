% compile_f_qmr.m
% Builds the f_qmr MEX function (f_qmr_mex.c + f_qmr.c) with OpenMP on
% macOS, Linux and Windows. Run it from this folder.
%
% Requirements
%   macOS   : Xcode command line tools (mex's default "Xcode with Clang").
%             OpenMP pragmas are enabled with "-Xpreprocessor -fopenmp"
%             and the runtime is MATLAB's OWN libiomp5.dylib: MATLAB
%             already loads it for MKL, and linking a second OpenMP
%             runtime (e.g. Homebrew libomp) crashes MATLAB with
%             "OMP: Error #179".
%   Linux   : gcc supported by your MATLAB release ("gcc" package).
%             Uses -fopenmp (libgomp). -std=gnu99 is forced because some
%             MATLAB releases default to -ansi, which rejects <complex.h>.
%   Windows : MinGW-w64 gcc ("MATLAB Support for MinGW-w64 C/C++/Fortran
%             Compiler" add-on; run  mex -setup C  to select it).
%             MSVC is NOT supported: it has no C99 <complex.h>.
%
% -R2017b selects the separate real/imaginary mxArray memory model used
% by f_qmr_mex.c (mxGetPr/mxGetPi); required on R2018a+, harmless before.
%
% Number of threads: set OMP_NUM_THREADS before starting MATLAB, or
% default to all cores.

src = {'f_qmr_mex.c', 'f_qmr.c'};
args = {'-R2017b'};

if ismac
    libiomp5 = fullfile(matlabroot, 'sys', 'os', computer('arch'), 'libiomp5.dylib');
    if ~isfile(libiomp5)
        error('compile_f_qmr:libiomp5', 'libiomp5.dylib not found: %s', libiomp5);
    end
    cflags  = '$CFLAGS -Xpreprocessor -fopenmp';
    ldflags = ['$LDFLAGS ' libiomp5];

elseif isunix
    cflags  = '$CFLAGS -std=gnu99 -fopenmp';
    ldflags = '$LDFLAGS -fopenmp';

elseif ispc
    cfg = mex.getCompilerConfigurations('C', 'Selected');
    if isempty(cfg)
        error('compile_f_qmr:nocompiler', ...
            'No C compiler selected. Install the MinGW-w64 add-on and run: mex -setup C');
    end
    if ~contains(lower(cfg(1).Name), 'mingw')
        error('compile_f_qmr:msvc', ...
            ['Selected compiler "%s" is not MinGW-w64. f_qmr uses C99 <complex.h>, ' ...
             'which MSVC does not provide. Install the MinGW-w64 add-on and run: mex -setup C'], ...
            cfg(1).Name);
    end
    cflags  = '$CFLAGS -std=gnu99 -fopenmp';
    ldflags = '$LDFLAGS -fopenmp';

else
    error('compile_f_qmr:os', 'Unsupported platform.');
end

mex(args{:}, ['CFLAGS=' cflags], ['LDFLAGS=' ldflags], src{:}, '-output', 'f_qmr');
fprintf('Built f_qmr.%s -- try test01.m\n', mexext);
