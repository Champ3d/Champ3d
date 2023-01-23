function V = f_multcolv(V1,V2)
% F_MULTCOLV returns column vector.
%--------------------------------------------------------------------------
% V = F_MULTCOLV(V1,V2); % V = V1 .* V2
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

V1 = f_tocolv(V1);
V2 = f_tocolv(V2);
V  = V1.*V2;

end