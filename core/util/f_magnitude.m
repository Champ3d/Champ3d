function VM = f_magnitude(V,varargin)
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

if isreal(V)
    VM  = sqrt(sum(V.^2));
else
    MV  = abs(V);
    ang = angle(V);
    % ---
    VM1 = MV .* sin(ang);
    VM1 = sqrt(sum(VM1.^2));
    VM2 = MV .* cos(ang);
    VM2 = sqrt(sum(VM2.^2));
    VM  = max([VM1;VM2]);
end

% VM = sqrt(sum(V .* conj(V)));
% if ~isreal(V)
%     VM = abs(VM);
% end
