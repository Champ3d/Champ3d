function Vnormalized = f_normalize(V,varargin)
% F_NORMALIZE returns the normalized vectors of an array of column vectors.
%--------------------------------------------------------------------------
% Vnormalized = F_NORMALIZE(V);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if nargin == 1
    dim = 1; % by default for column vector row array
else
    dim = varargin{1}; % put 2 for row vector column array
end

%--------------------------------------------------------------------------
VM = sqrt(sum(V.^2, dim));
Vnormalized = V ./ VM;
Vnormalized(:,VM <= eps) = 0;

end



