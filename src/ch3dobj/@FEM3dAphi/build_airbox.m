%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_airbox(obj)
% ---
if isempty(obj.airbox)
    if ~isfield(obj.parent_mesh.dom,'default_domain')
        obj.parent_mesh.add_default_domain;
    end
    obj.add_airbox('id','default_airbox','id_dom3d','default_domain');
end
% ---
gid_elem = [];
gid_inner_edge = [];
% ---
phydom_type = 'airbox';
% ---
allphydom = fieldnames(obj.(phydom_type));
% ---
for i = 1:length(allphydom)
    % ---
    id_phydom = allphydom{i};
    % ---
    phydom = obj.(phydom_type).(id_phydom);
    dom = phydom.dom;
    % ---
    gid_elem = [gid_elem dom.gid.gid_elem];
    gid_inner_edge = [gid_inner_edge dom.gid.gid_inner_edge];
    % ---
    obj.(phydom_type).(id_phydom).matrix.gid_elem = gid_elem;
    obj.(phydom_type).(id_phydom).matrix.gid_inner_edge = gid_inner_edge;
    % ---
end

end