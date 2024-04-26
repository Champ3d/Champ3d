function [solution,flag,relres,niter,resvec] = f_qmr(S,F,varargin)
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
arglist = {'tolerance','max_iter'};

% --- default input value
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

f_fprintf(0,'Solve system with',1,mfilename,0,'\n');
tic
% ---
precon = sqrt(diag(diag(S)));
[solution,flag,relres,niter,resvec] = qmr(S,F,tolerance,max_iter,precon.',precon);
% ---
f_fprintf(0,'--- in',1,toc,0,'s \n');
f_fprintf(0,'------ niter',1,niter,0,', relres',1,relres,0,'\n');





