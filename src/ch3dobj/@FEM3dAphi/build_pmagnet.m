%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_pmagnet(obj)
phydom_type = 'pmagnet';
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
    parent_mesh = dom.parent_mesh;
    gid_elem    = dom.gid_elem;
    % ---
    br = obj.(phydom_type).(id_phydom).br.get_on(dom);
    wfbr = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',br);
    % ---
    obj.(phydom_type).(id_phydom).matrix.gid_elem = gid_elem;
    obj.(phydom_type).(id_phydom).matrix.wfbr = wfbr;
end
end