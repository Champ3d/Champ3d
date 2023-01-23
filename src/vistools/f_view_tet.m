function f_view_tet(node,elem)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
f1 = [elem(1,:) elem(2,:) elem(3,:)];
f2 = [elem(1,:) elem(2,:) elem(4,:)];
f3 = [elem(1,:) elem(3,:) elem(4,:)];
f4 = [elem(2,:) elem(3,:) elem(4,:)];

figure;
patchinfo.Vertices = node.';
patchinfo.Faces = f1.'; patch(patchinfo); hold on
patchinfo.Faces = f2.'; patch(patchinfo); hold on
patchinfo.Faces = f3.'; patch(patchinfo); hold on
patchinfo.Faces = f4.'; patch(patchinfo); hold on

end