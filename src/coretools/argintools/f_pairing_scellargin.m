function [argin1p,argin2p] = f_pairing_scellargin(argin1,argin2)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


% --- default output value
argin1p = [];
argin2p = [];

%--------------------------------------------------------------------------
argin1 = f_to_scellargin(argin1);
argin2 = f_to_scellargin(argin2);
%--------------------------------------------------------------------------
if length(argin1) > 1 && length(argin2) > 1
    % cannot pairing, return the same
    argin1p = argin1;
    argin2p = argin2;
end
%--------------------------------------------------------------------------
if length(argin1) > 1 && length(argin2) == 1
    argin1p = argin1;
    for i = 1:length(argin1)
        argin2p{i} = argin2{1};
    end
elseif length(argin2) > 1 && length(argin1) == 1
    argin2p = argin2;
    for i = 1:length(argin2)
        argin1p{i} = argin1{1};
    end
else
    argin1p = argin1;
    argin2p = argin2;
end

