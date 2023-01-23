function VM = f_norm(V,varargin)
% F_NORM returns the norm of vectors in an array of column vectors.
%--------------------------------------------------------------------------
% VM = F_NORM(V);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

ntype = 2;
[dim,len] = size(V);

if nargin > 1
    ntype = varargin{1};
end

switch ntype
    case 2
        VM = zeros(1,len);
        for i = 1:dim
            VM = VM + V(i,:).^2;
        end
        VM = sqrt(VM);
end


end