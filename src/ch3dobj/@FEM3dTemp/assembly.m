%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function assembly(obj)

%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Assembly',1,class(obj),0,'\n');
%--------------------------------------------------------------------------
obj.build;
%--------------------------------------------------------------------------
if obj.assembly_done
    return
end
%--------------------------------------------------------------------------
parent_mesh = obj.parent_mesh;
nb_edge = parent_mesh.nb_edge;
nb_node = parent_mesh.nb_node;
%--------------------------------------------------------------------------
obj.matrix.id_node_t  = [];
obj.matrix.lambdawewe = sparse(nb_edge,nb_edge);
obj.matrix.rhocpwnwn  = sparse(nb_node,nb_node);
obj.matrix.hwnwn      = sparse(nb_node,nb_node);
obj.matrix.pswn       = sparse(nb_node,1);
obj.matrix.pvwn       = sparse(nb_node,1);
obj.dof.temp          = sparse(nb_node,1);
%--------------------------------------------------------------------------
obj.matrix.id_elem_nomesh = [];
%--------------------------------------------------------------------------
allowed_physical_dom = {'thconductor','thcapacitor','convection',...
                        'ps','pv'};
%--------------------------------------------------------------------------
for i = 1:length(allowed_physical_dom)
    phydom_type = allowed_physical_dom{i};
    % ---
    if isprop(obj,phydom_type)
        if isempty(obj.(phydom_type))
            continue
        end
    else
        continue
    end
    % ---
    allphydomid = fieldnames(obj.(phydom_type));
    for j = 1:length(allphydomid)
        id_phydom = allphydomid{j};
        phydom = obj.(phydom_type).(id_phydom);
        % ---
        f_fprintf(0,['Assembly #' phydom_type],1,id_phydom,0,'\n');
        % ---
        phydom.assembly;
    end
end
%--------------------------------------------------------------------------
id_node_t = unique(obj.matrix.id_node_t);
%--------------------------------------------------------------------------
%
%               MATRIX SYSTEM
%
%--------------------------------------------------------------------------
% --- LSH
delta_t = 1;
% ---
LHS = (1./delta_t) .* obj.matrix.rhocpwnwn + ...
      obj.parent_mesh.discrete.grad.' * obj.matrix.lambdawewe * obj.parent_mesh.discrete.grad + ...
      obj.matrix.hwnwn;
% ---
LHS = LHS(id_node_t,id_node_t);
%--------------------------------------------------------------------------
% --- RHS
Temp_prev = 0;
RHS = obj.matrix.pvwn + obj.matrix.pswn + ...
      (1./delta_t) .* obj.matrix.rhocpwnwn * Temp_prev;
% ---
RHS = RHS(id_node_t,1);
%--------------------------------------------------------------------------
obj.assembly_done = 1;
%--------------------------------------------------------------------------
sol = f_solve_axb(LHS,RHS);
%--------------------------------------------------------------------------
obj.dof.temp = zeros(nb_node,1);
obj.dof.temp(id_node_t) = sol;
%--------------------------------------------------------------------------
obj.fields.tempv = obj.parent_mesh.field_wn('dof',obj.dof.temp);
obj.fields.temp  = obj.dof.temp;

