function [argin1p,argin2p] = f_pairing_dcellargin(argin1,argin2)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if ~iscell(argin1) || ~iscell(argin2)
    error([mfilename ' : #argin1, #argin2 msut be cell !']);
end
%--------------------------------------------------------------------------
if length(argin1) > 1 && length(argin2) > 1
    % cannot pairing, return the same
    argin1p = argin1;
    argin2p = argin2;
end
%--------------------------------------------------------------------------
if length(argin1) == 1
    argin1p = f_to_dcellargin(argin1,'duplicate',length(argin2));
    argin2p = argin2;
end
% ---
if length(argin2) == 1
    argin1p = argin1;
    argin2p = f_to_dcellargin(argin2,'duplicate',length(argin1));
end



