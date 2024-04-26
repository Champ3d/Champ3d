function flag = f_isempty(argin)
%F_TO_SCELLARGIN : returns a single cell argin from double cell or string
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

flag = true;
argin = f_to_scellargin(argin);

for i = 1:length(argin)
    if ~isempty(argin{i})
        flag = false;
        break;
    end
end
