function gtensor = f_tensoroxy(values,angle)
% F_TENSOROXY returns the physical property tensor in global coordinates of
% material defined on OXY plane.
%--------------------------------------------------------------------------
% gtensor = F_TENSOROXY([main_sigma ort1_sigma ort2_sigma],angle);
% gtensor = F_TENSOROXY([10 1 1],45);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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


