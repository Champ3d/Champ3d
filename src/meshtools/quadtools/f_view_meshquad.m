function f_view_meshquad(p2d,t2d,idElem,color)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
clear msh;
msh.Vertices = p2d.';
msh.Faces = t2d(1:4,idElem).';
msh.FaceColor = color;
msh.EdgeColor = 'k';
patch(msh); axis equal; alpha(0.5);
node1x = mean(p2d(1,t2d(1:4,idElem(1))));
node1y = mean(p2d(2,t2d(1:4,idElem(1))));
text(node1x, node1y, strrep(inputname(3),'_',''));
