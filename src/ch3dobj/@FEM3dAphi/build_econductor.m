%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_econductor(obj)

% ---
phydom_type = 'econductor';
% ---
if isempty(obj.(phydom_type))
    return
else
    allphydom = fieldnames(obj.(phydom_type));
end
% ---
for i = 1:length(allphydom)
    % ---
    id_phydom = allphydom{i};
    % ---
    phydom = obj.(phydom_type).(id_phydom);
    dom = phydom.dom;
    % ---
    if ~phydom.to_be_rebuild
        break
    end
    % ---
    f_fprintf(0,['Build #' phydom_type],1,id_phydom,0,'\n');
    % ---
    parent_mesh = dom.parent_mesh;
    gid_elem    = dom.gid_elem;
    % ---
    elem = parent_mesh.elem(:,gid_elem);
    % ---
    gid_node_phi = f_uniquenode(elem);
    % ---
    sigma_array = obj.(phydom_type).(id_phydom).sigma.get_on(dom);
    % ---
    sigmawewe = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
    % ---
    obj.(phydom_type).(id_phydom).matrix.gid_elem = gid_elem;
    obj.(phydom_type).(id_phydom).matrix.gid_node_phi = gid_node_phi;
    obj.(phydom_type).(id_phydom).matrix.sigmawewe = sigmawewe;
    obj.(phydom_type).(id_phydom).matrix.sigma_array = sigma_array;
    % ---
    phydom.to_be_rebuild = 0;
end

end