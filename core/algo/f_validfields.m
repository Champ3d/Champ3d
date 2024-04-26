function valide_field = f_validfields(id2test,str)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

all_id = fieldnames(str);
valide_field = [];
valid_id = f_validid(id2test,all_id);
for j = 1:length(valid_id)
    valide_field = [valide_field str.(valid_id{j})];
end
