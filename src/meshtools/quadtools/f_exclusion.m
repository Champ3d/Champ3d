function V = f_exclusion(V1,V2)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------

V1 = sort(V1);
V2 = sort(V2);

dim = size(V1,1);
lenV1 = size(V1,2);
lenV2 = size(V2,2); 
S1  = zeros(1,lenV1);
S2  = zeros(1,lenV2);
for i = 1:dim
    S1 = S1 + V1(i,:) .* (pi^(i-1));
    S2 = S2 + V2(i,:) .* (pi^(i-1)); 
end

[~,iS] = setdiff(S1,S2);
V = V1(:,iS);