%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function solve(obj)

%--------------------------------------------------------------------------
f_fprintf(0,'Solve',1,class(obj),0,'\n');
f_fprintf(0,'   ');
%--------------------------------------------------------------------------
erro0 = 1;
tole0 = 1e-3;
maxi0 = 3;
erro1 = 1;
tole1 = 1e-6;
maxi1 = 1e3;
%--------------------------------------------------------------------------
nite0 = 0;
% ---
while erro0 > tole0 & nite0 < maxi0 
    % ---
    obj.build_done = 0;
    obj.assembly_done = 0;
    obj.assembly;
    % ---
    nite0 = nite0 + 1;
    f_fprintf(0,'--- iter-out',1,nite0);
    % ---
    if nite0 == 1
        x0 = [];
    end
    % ---
    M = sqrt(diag(diag(obj.matrix.LHS)));
    [x,flag,relres,niter,resvec] = ...
        qmr(obj.matrix.LHS,obj.matrix.RHS,tole1,maxi1,M.',M,x0);
    % ---
    if nite0 == 1
        erro0 = 1;
        x0 = x;
    elseif niter > 1
        erro0 = norm(x0 - x)/norm(x0);
        x0 = x;
    else
        erro0 = 0;
        x = x0;
    end
    % ---
    f_fprintf(0,'e',1,erro0,0,'\n');
    f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
    %----------------------------------------------------------------------
    % --- postpro
    id_node_t = obj.matrix.id_node_t;
    nb_node = obj.parent_mesh.nb_node;
    %----------------------------------------------------------------------
    obj.dof.temp = zeros(nb_node,1);
    obj.dof.temp(id_node_t) = x;
    %----------------------------------------------------------------------
    obj.fields.tempv = obj.parent_mesh.field_wn('dof',obj.dof.temp);
    obj.fields.temp  = obj.dof.temp;
    Temp_prev = obj.dof.temp;
    %----------------------------------------------------------------------
    obj.postpro;
    %----------------------------------------------------------------------
end
