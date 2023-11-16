function V = f_multcolv(V1,V2)
% F_MULTCOLV returns column vector.
%--------------------------------------------------------------------------
% V = F_MULTCOLV(V1,V2); % V = V1 .* V2
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

V1 = f_tocolv(V1);
V2 = f_tocolv(V2);
V  = V1.*V2;

end