function design3d = f_solvethermic(design3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
fprintf('Solving system ... \n');

for i = 1:(nargin-1)/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i};']);
end

if ~exist('sol_option','var')
    sol_option.solver = 'gmres';
    sol_option.tolerance = 1e-7;
    sol_option.nb_iter = 1e4;
else
    if ~isfield(sol_option,'solver')
        sol_option.solver = 'gmres';
    end
    if ~isfield(sol_option,'tolerance')
        sol_option.tolerance = 1e-7;
    end
    if ~isfield(sol_option,'nb_iter')
        sol_option.nb_iter = 1e4;
    end
end

%--------------------------------------------------------------------------
nbNode = design3d.mesh.nbNode;
%--------------------------------------------------------------------------
tic
temp0 = zeros(length(design3d.Thermic.id_node_temp),1);
temp  = zeros(ceil(design3d.Thermic.t_end/design3d.Thermic.delta_t),nbNode);
time = 0;
itime = 0;
if strcmpi(sol_option.solver, 'gmres')
    %--------------------------------------------------------------------------
    [L,U] = ilu(design3d.Thermic.S,struct('type','ilutp','droptol',1e-3));
    while time <= design3d.Thermic.t_end
        itime = itime + 1;
        time  = itime * design3d.Thermic.delta_t
        if time <= design3d.Thermic.t_heat
            RHS = design3d.Thermic.pWn + design3d.Thermic.SWnWn * temp0;
        else
            RHS = design3d.Thermic.SWnWn * temp0;
        end
        [solution,flag,relres,iter,resvec] = gmres(design3d.Thermic.S,RHS,...
                     5,sol_option.tolerance,sol_option.nb_iter,L,U,temp0);
        temp(itime,design3d.Thermic.id_node_temp) = solution.';
        temp0 = solution;
    end
end

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
design3d.Thermic.Temp = temp;
design3d.Thermic.flag = flag;
design3d.Thermic.relres = relres;
design3d.Thermic.iter = iter;
design3d.Thermic.resvec = resvec;
design3d.Thermic.residual = relres;
%--------------------------------------------------------------------------
fprintf('Time to inverse system : %.4f s \n',toc);


