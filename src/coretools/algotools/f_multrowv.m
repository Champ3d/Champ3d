function V = f_multrowv(V1,V2)
% F_MULTROWV returns row vector.
%--------------------------------------------------------------------------
% V = F_MULTROWV(V1,V2);
%    --> V = V1 .* V2
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

V1 = f_torowv(V1);
V2 = f_torowv(V2);
V  = V1.*V2;

end