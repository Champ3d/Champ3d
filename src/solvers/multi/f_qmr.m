function [solution,flag,relres,niter,resvec] = f_qmr(S,F,varargin)
% F_QMR ...
%--------------------------------------------------------------------------
% [solution,flag,relres,niter,resvec] =
% F_QMR(S,F,'tolerance',1e-7,'nb_iter',1000);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if nargin > 2
    sol_option = varargin{1};
else
    sol_option.tolerance = 1e-6;
    sol_option.nb_iter = 3e4;
end

if ~isfield(sol_option,'tolerance')
    sol_option.tolerance = 1e-6;
end
if ~isfield(sol_option,'nb_iter')
    sol_option.nb_iter = 3e4;
end

f_fprintf(0,'Solve system with',1,mfilename,0,'\n');
tic
% ---
precon = sqrt(diag(diag(S)));
[solution,flag,relres,niter,resvec] = qmr(S,F,sol_option.tolerance,sol_option.nb_iter,precon.',precon);
% ---
f_fprintf(0,'--- in',1,toc,0,'s \n');
f_fprintf(0,'------ niter',1,niter,0,', relres',1,relres,0,'\n');





