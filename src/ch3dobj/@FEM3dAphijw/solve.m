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


nite0 = 0;
while erro0 > tole0 & nite0 < maxi0 
    % ---
    obj.build_done = 0;
    obj.assembly_done = 0;
    obj.assembly;
    % ---
    nite0 = nite0 + 1
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
    niter
    relres
    erro0
    %----------------------------------------------------------------------
    % --- postpro
    id_edge_a_unknown = obj.matrix.id_edge_a_unknown;
    id_node_phi_unknown = obj.matrix.id_node_phi_unknown;
    nb_edge = obj.parent_mesh.nb_edge;
    nb_node = obj.parent_mesh.nb_node;
    % ---
    len_sol = length(x);
    len_a_unknown = length(id_edge_a_unknown);
    len_phi_unknown = length(id_node_phi_unknown);
    % ---
    obj.dof.a   = zeros(nb_edge,1);
    obj.dof.phi = zeros(nb_node,1);
    obj.dof.a(id_edge_a_unknown)     = x(1:len_a_unknown);
    obj.dof.phi(id_node_phi_unknown) = x(len_a_unknown+1 : ...
        len_a_unknown+len_phi_unknown);
    %----------------------------------------------------------------------
    obj.dof.dphiv = 0;
    if (len_a_unknown + len_phi_unknown) < len_sol
        obj.dof.dphiv = x(len_a_unknown+len_phi_unknown+1 : len_sol);
    end
    %----------------------------------------------------------------------
    freq = obj.frequency;
    jome = 1j*2*pi*freq;
    % ---
    obj.dof.b = obj.parent_mesh.discrete.rot * obj.dof.a;
    obj.dof.e = -jome .* (obj.dof.a + obj.parent_mesh.discrete.grad * obj.dof.phi);
    %----------------------------------------------------------------------
    obj.postpro;
    %----------------------------------------------------------------------
end
