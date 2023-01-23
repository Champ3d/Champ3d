function design3d = f_create_design3d(varargin)


%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

for i = 1:nargin/2
    design3d.(lower(varargin{2*i-1})) = varargin{2*i};
end