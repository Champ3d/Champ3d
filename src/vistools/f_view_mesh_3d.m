function f_view_mesh_3d(dom3D,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

for i = 1:(nargin-1)/2
    eval([varargin{2*i-1} '= varargin{2*i};']);
end

node = dom3D.mesh.node;
elem = dom3D.mesh.elem;
face = dom3D.mesh.face;
face_in_elem = dom3D.mesh.face_in_elem;

iElem = 1:size(elem,2);
Color = 'gr';

if strcmpi(Type,'volume')

    t_f=[face_in_elem(1,iElem) face_in_elem(2,iElem) face_in_elem(3,iElem) ...
         face_in_elem(4,iElem) face_in_elem(5,iElem)] ;

    t_f=unique(t_f);

    % 1/ triangle
    ind_tria=find(face(4,t_f)==0);
    fac=[face(1,t_f(ind_tria));face(2,t_f(ind_tria));face(3,t_f(ind_tria))];
    patchinfo.Vertices = node.';
    patchinfo.Faces = fac.';
    patchinfo.FaceColor = Color;
    patch(patchinfo); hold on


    % 2/ quad
    ind_quad=setdiff(1:length(t_f),ind_tria);
    fac=[face(1,t_f(ind_quad));face(2,t_f(ind_quad));face(3,t_f(ind_quad));face(4,t_f(ind_quad))];
    patchinfo.Vertices = node.';
    patchinfo.Faces = fac.';
    patchinfo.FaceColor = Color;
    patch(patchinfo);
    alpha(0.5);
    axis equal
    axis image
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    view(3);
    hold off

elseif strcmpi(Type,'surface')

    t_f=unique(iElem);

    % 1/ triangle
    ind_tria=find(face(4,t_f)==0);
    fac=[face(1,t_f(ind_tria));face(2,t_f(ind_tria));face(3,t_f(ind_tria))];
    patchinfo.Vertices = node.';
    patchinfo.Faces = fac.';
    patchinfo.FaceColor = Color;
    patch(patchinfo); hold on


    % 2/ quad
    ind_quad=setdiff(1:length(t_f),ind_tria);
    fac=[face(1,t_f(ind_quad));face(2,t_f(ind_quad));face(3,t_f(ind_quad));face(4,t_f(ind_quad))];
    patchinfo.Vertices = node.';
    patchinfo.Faces = fac.';
    patchinfo.FaceColor = Color;
    patch(patchinfo);
    alpha(0.5);
    axis equal
    axis image
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    view(3);
    hold off
end


