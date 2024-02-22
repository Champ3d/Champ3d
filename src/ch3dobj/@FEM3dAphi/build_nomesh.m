%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_nomesh(obj)
% ---
gid_elem = [];
gid_inner_edge = [];
gid_inner_node = [];
% ---
phydom_type = 'nomesh';
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
    gid_elem = [gid_elem dom.gid.gid_elem];
    gid_inner_edge = [gid_inner_edge dom.gid.gid_inner_edge];
    gid_inner_node = [gid_inner_node dom.gid.gid_inner_edge];
    % ---
    obj.(phydom_type).(id_phydom).matrix.gid_elem = gid_elem;
    obj.(phydom_type).(id_phydom).matrix.gid_inner_edge = gid_inner_edge;
    obj.(phydom_type).(id_phydom).matrix.gid_inner_node = gid_inner_node;
    % ---
end

end