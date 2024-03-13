%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function postpro(obj)

%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Postprocessing',1,class(obj),0,'\n');
f_fprintf(0,'   ');
%--------------------------------------------------------------------------
parent_mesh = obj.parent_mesh;
nb_elem = parent_mesh.nb_elem;
nb_face = parent_mesh.nb_face;
nb_edge = parent_mesh.nb_edge;
nb_node = parent_mesh.nb_node;
%--------------------------------------------------------------------------
obj.fields.av = obj.parent_mesh.field_we('dof',obj.dof.a);
obj.fields.bv = obj.parent_mesh.field_wf('dof',obj.dof.b);
obj.fields.ev = obj.parent_mesh.field_we('dof',obj.dof.e);
obj.fields.phiv = obj.parent_mesh.field_wn('dof',obj.dof.phi);
obj.fields.phi = obj.dof.phi;
% -------------------------------------------------------------------------
obj.fields.jv = sparse(3,nb_elem);
obj.fields.pv = sparse(1,nb_elem);
obj.fields.js = sparse(2,nb_face);
obj.fields.ps = sparse(1,nb_face);
%--------------------------------------------------------------------------
%allowed_physical_dom = {'econductor','sibc','coil'};
allowed_physical_dom = {'econductor','sibc'};
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
        f_fprintf(0,['--- #' phydom_type],1,id_phydom,0,'\n');
        % ---
        phydom.postpro;
    end
end
%--------------------------------------------------------------------------
f_fprintf(0,'\n');
