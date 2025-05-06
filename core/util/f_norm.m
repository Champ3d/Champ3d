function VM = f_norm(V,varargin)
% F_NORM returns the norm of vectors in an array of column vectors.
%--------------------------------------------------------------------------
% VM = F_NORM(V);
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

ntype = 2;

if nargin > 1
    ntype = varargin{1};
end

switch ntype
    case 2
        VM = sqrt(sum(V.^2));
    otherwise
        VM = sqrt(sum(V.^2));
end

end