function [solution,flag,relres,niter,resvec] = f_solve_axb(S,F,varargin)
% F_QMR ...
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


% --- valid argument list (to be updated each time modifying function)
arglist = {'platform','solver','tolerance','max_iter'};

% --- default input value
solver = 'qmr';
platform = 'multiplateforme';
tolerance = 1e-6;
max_iter  = 3e4;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if any(f_strcmpi(platform,'multiplateforme'))
    if any(f_strcmpi(solver,'qmr'))
        [solution,flag,relres,niter,resvec] = f_qmr(S,F,'tolerance',tolerance,'max_iter',max_iter);
    end
end

