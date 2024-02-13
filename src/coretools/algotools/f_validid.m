function valide_id = f_validid(id2test,all_id)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if contains(id2test,'...')
    id2test = replace(id2test,'...','');
    check_valide = regexp(all_id,[id2test '\w*']);
    % ---
    valide_id = {};
    k = 0;
    for i = 1:length(check_valide)
        if check_valide{i} == 1
            k = k + 1;
            valide_id{k} = all_id{i};
        end
    end
else
    check_valide = strcmpi(id2test,all_id);
    % ---
    valide_id = {};
    k = 0;
    for i = 1:length(check_valide)
        if check_valide(i) == 1
            k = k + 1;
            valide_id{k} = all_id{i};
        end
    end
end
