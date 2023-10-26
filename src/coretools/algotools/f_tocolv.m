function vcol = f_tocolv(X)
% F_TOCOLV returns the corresponding column vector of the input vector.
%--------------------------------------------------------------------------
% vcol = F_TOCOLV(X)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

vcol = squeeze(X);
s = size(vcol,2);
if s > 1
    vcol = vcol.';
end

end