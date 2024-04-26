function vrow = f_torowv(X)
% F_TOROWV returns the corresponding row vector of the input vector.
%--------------------------------------------------------------------------
% vrow = F_TOROWV(X)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

vrow = squeeze(X);
s = size(vrow,1);
if s > 1
    vrow = vrow.';
end

end