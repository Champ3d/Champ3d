function [solution,flag,relres,niter,resvec] = f_qmr(S,F,varargin)
% F_QMR ...
%--------------------------------------------------------------------------
% [solution,flag,relres,niter,resvec] =
% F_QMR(S,F,'tolerance',1e-7,'nb_iter',1000);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if nargin > 2
    sol_option = varargin{1};
else
    sol_option.tolerance = 1e-7;
    sol_option.nb_iter = 1e4;
end

if ~isfield(sol_option,'tolerance')
    sol_option.tolerance = 1e-7;
end
if ~isfield(sol_option,'nb_iter')
    sol_option.nb_iter = 1e4;
end

fprintf('Solving system ... ');
tic
% ---
precon = sqrt(diag(diag(S)));
[solution,flag,relres,niter,resvec] = qmr(S,F,sol_option.tolerance,sol_option.nb_iter,precon.',precon);
% ---
% precon = ichol(S, struct('type','ict','droptol',1e-2));
% [solution,flag,relres,niter,resvec] = pcg(S,F,sol_option.tolerance,sol_option.nb_iter,precon,precon.');
% ---
fprintf('%.4f s \n',toc);





