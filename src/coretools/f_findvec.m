function ivec = f_findvec(vin,vref)
% F_FINDVEC returns the idx of vectors in a array of reference vectors
%--------------------------------------------------------------------------
% FIXED INPUT
% vin : nD x nb_vectors
% vref : nD x nb_vectors
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% ivec : indices of found vectors.
%--------------------------------------------------------------------------
% EXAMPLE
% ivec = F_FINDVEC(vin,vref);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


vref = sort(vref);
vin  = sort(vin);
[dimref,lenref] = size(vref);
[dimin,lenin]   = size(vin);
if dimref ~= dimin
    error([mfilename ': #vref and #vin do not have the same dimension !']);
end
%-----
iref = 1:lenref;
sref = zeros(1,lenref);
for i = 1:dimref
    sref = sref + vref(i,:) .* (pi^(i-1));
end
%-----
sin = zeros(1,lenin);
for i = 1:dimin
    sin = sin + vin(i,:) .* (pi^(i-1));
end
%-----
ivec = interp1(sref,iref,sin);
%--------------------------------------------------------------------------
end