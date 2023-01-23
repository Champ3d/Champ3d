function vrow = f_torowv(X)
% F_TOROWV returns the corresponding row vector of the input vector.
%--------------------------------------------------------------------------
% vrow = F_TOROWV(X)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

vrow = squeeze(X);
s = size(vrow,1);
if s > 1
    vrow = vrow.';
end

end