function Vnormalized = f_normalize(V)
% F_NORMALIZE returns the normalized vectors of an array of column vectors.
%--------------------------------------------------------------------------
% Vnormalized = F_NORMALIZE(V);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

VM = sqrt(sum(V.^2));
Vnormalized = V ./ VM;
Vnormalized(:,VM <= eps) = 0;

end



