%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

function ang = f_vecangle(Va,Vb)
arguments
    Va    % 2,3 x n
    Vb
end
% ---
dim = size(Va,1);
% ---
if dim == 2
    x1 = Va(1,:);
    y1 = Va(2,:);
    x2 = Vb(1,:);
    y2 = Vb(2,:);
    % --- right-handed rotation from Va to Vb
    ang = atan2(x1.*y2-y1.*x2,x1.*x2+y1.*y2) .* 180/pi;
elseif dim == 3
    % --- XTODO
    % right-handed rotation from Va to Vb, |Vn| = 1
    % ang = atan2((Va x Vb).Vn, Va.Vb);
else
    ang = [];
end

end