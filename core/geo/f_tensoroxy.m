function gtensor = f_tensoroxy(values,angle)
% F_TENSOROXY returns the physical property tensor in global coordinates of
% material defined on OXY plane.
%--------------------------------------------------------------------------
% gtensor = F_TENSOROXY([main_sigma ort1_sigma ort2_sigma],angle);
% gtensor = F_TENSOROXY([10 1 1],45);
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

%--------------------------------------------------------------------------
% physical value
main_value = values(1);
ort1_value = values(2);
ort2_value = values(3);

main_dir = [+cosd(angle) +sind(angle) 0]; % [!] function to compute these vectors (LOXY_A, LOXZ_A), ...)
ort1_dir = [-sind(angle) +cosd(angle) 0]; % 
ort2_dir = [0 0 1];

%--------------------------------------------------------------------------
% local coordinates system
ltensor = [main_value 0           0; ...
           0          ort1_value  0; ...
           0          0           ort2_value];

lix = main_dir./norm(main_dir);
liy = ort1_dir./norm(ort1_dir);
liz = ort2_dir./norm(ort2_dir);
lcoor = [lix; liy; liz];

%--------------------------------------------------------------------------
% global coordinates system
gix = [1 0 0];
giy = [0 1 0];
giz = [0 0 1];
gcoor = [gix; giy; giz];


%--------------------------------------------------------------------------
% transformation matrix local --> global
TM = zeros(3,3);
for i = 1:3
    for j = 1:3
        TM(i,j) = dot(gcoor(i,:),lcoor(j,:));
    end
end

gtensor = TM' * ltensor * TM;


end


