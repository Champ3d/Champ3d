function [argin1p,argin2p] = f_pairing_cellargin(argin1,argin2)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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
%--------------------------------------------------------------------------
if length(argin2) == 1
    argin1p = argin1;
    argin2p = f_to_dcellargin(argin2,'duplicate',length(argin1));
end



