function vcol = f_tocolv(X)
% F_TOCOLV returns the corresponding column vector of the input vector.
%--------------------------------------------------------------------------
% vcol = F_TOCOLV(X)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

vcol = squeeze(X);
s = size(vcol,2);
if s > 1
    vcol = vcol.';
end

end