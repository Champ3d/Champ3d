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

[dim,len] = size(V);

VM = zeros(1,len);
for i = 1:dim
    VM = VM + V(i,:).^2;
end
VM = sqrt(VM);

Vnormalized = zeros(dim,len);

for i = 1:dim
    Vnormalized(i,:)  = V(i,:)./VM;
end

Vnormalized(:,VM <= eps) = 0;

end