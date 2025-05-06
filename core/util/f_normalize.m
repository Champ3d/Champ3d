function Vnormalized = f_normalize(V,varargin)
% F_NORMALIZE returns the normalized vectors of an array of column vectors.
%--------------------------------------------------------------------------
% Vnormalized = F_NORMALIZE(V);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
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



