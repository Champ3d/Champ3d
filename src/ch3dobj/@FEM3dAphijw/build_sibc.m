%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build_sibc(obj)

phydom_type = 'sibc';
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
    gid_face = dom.gid_face;
    nb_face  = length(gid_face);
    % ---
    id_node_phi = f_uniquenode(dom.parent_mesh.face(:,gid_face));
    % ---
    sigma_array  = obj.(phydom_type).(id_phydom).sigma.get_on(dom);
    mur_array    = obj.(phydom_type).(id_phydom).mur.get_on(dom);
    cparam_array = obj.(phydom_type).(id_phydom).cparam.get_on(dom);
    % ---
    mu0 = 4 * pi * 1e-7;
    fr = obj.frequency;
    skindepth = sqrt(2./(2*pi*fr.*(mu0.*mur_array).*sigma_array));
    % ---
    z_sibc = (1+1j)./(skindepth.*sigma_array) .* ...
        (1 + (1-1j)/4 .* skindepth .* cparam_array);
    z_sibc = obj.column_array(z_sibc,'nb_elem',nb_face);
    % ---
    dom.build_submesh;
    submesh = dom.submesh;
    for k = 1:length(submesh)
        sm = submesh{k};
        sm.build_intkit;
        % ---
        lid_face_  = sm.lid_face;
        g_sibc = 1./z_sibc(lid_face_);
        gsibcwewe{k} = sm.cwewe('coefficient',g_sibc);
        % ---
        gid_face_{k} = sm.gid_face;
    end
    % ---
    obj.(phydom_type).(id_phydom).matrix.id_node_phi = id_node_phi;
    % ---
    obj.(phydom_type).(id_phydom).matrix.gsibcwewe = gsibcwewe;
    obj.(phydom_type).(id_phydom).matrix.gid_face = gid_face_;
    obj.(phydom_type).(id_phydom).matrix.sigma_array = sigma_array;
    % ---
    phydom.to_be_rebuild = 0;
end
end