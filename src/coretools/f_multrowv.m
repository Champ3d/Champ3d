function V = f_multrowv(V1,V2)
% F_MULTROWV returns row vector.
%--------------------------------------------------------------------------
% V = F_MULTROWV(V1,V2);
%    --> V = V1 .* V2
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

V1 = f_torowv(V1);
V2 = f_torowv(V2);
V  = V1.*V2;

end