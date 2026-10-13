function valide_id = f_validid(id2test,all_id)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if contains(id2test,'...')
    if strcmpi(id2test,'...') == 1
        valide_id = all_id;
    else
        id2test = replace(id2test,'...','');
        check_valide = regexp(string(all_id),string(id2test) + '\w*');
        %check_valide = regexp(all_id,[id2test '\w*']);
        % ---
        valide_id = {};
        k = 0;
        for i = 1:length(check_valide)
            if check_valide{i} == 1
                k = k + 1;
                valide_id{k} = all_id{i};
            end
        end
    end
else
    check_valide = strcmpi(string(id2test),string(all_id));
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
