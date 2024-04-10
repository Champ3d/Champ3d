%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function build(obj)

%--------------------------------------------------------------------------
if obj.build_done
    return
end
%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Build',1,class(obj),0,'\n');
f_fprintf(0,'   ');
% ---
parent_mesh = obj.parent_mesh;
% ---
if ~parent_mesh.build_meshds_done
    parent_mesh.build_meshds;
end
% ---
if ~parent_mesh.build_discrete_done
    parent_mesh.build_discrete;
end
% ---
if ~parent_mesh.build_intkit_done
    parent_mesh.build_intkit;
end
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
        % ---
        f_fprintf(0,['Build #' phydom_type],1,id_phydom,0,'\n');
        % ---
        phydom = obj.(phydom_type).(id_phydom);
        % ---
        phydom.reset;
        phydom.build;
    end
end
%--------------------------------------------------------------------------
obj.build_done = 1;
%--------------------------------------------------------------------------
return