%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_mconductor(obj)

phydom_type = 'mconductor';
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
    mu0 = 4 * pi * 1e-7;
    nu0 = 1/mu0;
    nu0nur = nu0 .* obj.(phydom_type).(id_phydom).mur.get_inverse_on(dom);
    % ---
    nu0nurwfwf = parent_mesh.cwfwf('id_elem',gid_elem,'coefficient',nu0nur);
    % ---
    obj.(phydom_type).(id_phydom).matrix.gid_elem = gid_elem;
    obj.(phydom_type).(id_phydom).matrix.nu0nurwfwf = nu0nurwfwf;
    % ---
    phydom.to_be_rebuild = 0;
end

end