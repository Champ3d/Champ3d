function [flatnode,flatface] = f_flatface(node,face)
% F_FLATFACE flats a 3D surface to 2D surface
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% face : nb_nodes_per_face x nb_faces
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% flatnode : nD x nb_nodes_per_face x nb_face
% flatface : array of faces filtered
%--------------------------------------------------------------------------
% EXAMPLE
% [flatnode,flatface] = F_FLATFACE(node,face);
%  --> flatnode(1,i,j) = local x of node i of face j
%      flatnode(2,i,j) = local y of node i of face j
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if any(face(end,:) == 0)
    filterface = f_filterface(face);
    face = filterface{1};
end
flatface  = face;
nvec      = f_chavec(node,face,'face');
nbNo_inFa = size(face,1);
nbFace    = size(face,2);
%--------------------------------------------------------------------------

Ox = zeros(3,nbFace);
Oy = zeros(3,nbFace);

%----------------------
Ox(1,:) = node(1,face(2,:)) - node(1,face(1,:));
Ox(2,:) = node(2,face(2,:)) - node(2,face(1,:));
Ox(3,:) = node(3,face(2,:)) - node(3,face(1,:));
MOx     = sqrt(Ox(1,:).^2 + Ox(2,:).^2 + Ox(3,:).^2);
Ox(1,:) = Ox(1,:)./MOx; % normalize
Ox(2,:) = Ox(2,:)./MOx;
Ox(3,:) = Ox(3,:)./MOx;

% ---------------------
Oy(1,:) = nvec(2,:).*Ox(3,:) - Ox(2,:).*nvec(3,:);
Oy(2,:) = nvec(3,:).*Ox(1,:) - Ox(3,:).*nvec(1,:);
Oy(3,:) = nvec(1,:).*Ox(2,:) - Ox(1,:).*nvec(2,:);
MOy     = sqrt(Oy(1,:).^2 + Oy(2,:).^2 + Oy(3,:).^2);
Oy(1,:) = Oy(1,:)./MOy; % normalize
Oy(2,:) = Oy(2,:)./MOy;
Oy(3,:) = Oy(3,:)./MOy;

%find((Ox(1,:).*Oy(1,:)+Ox(2,:).*Oy(2,:)+Ox(3,:).*Oy(3,:)))


% ------------------------Transformation (Flating)-------------------------

flatnode = zeros(2,nbNo_inFa,nbFace);

% 1/ point 1
flatnode(1,1,:) = 0;
flatnode(2,1,:) = 0;

% 2/ point 2
flatnode(1,2,:) = MOx;
flatnode(2,2,:) = 0;

% 3/ point 3 -> nbNo_inFa
for i = 3:nbNo_inFa
    p1pi(1,:) = node(1,face(i,:)) - node(1,face(1,:));
    p1pi(2,:) = node(2,face(i,:)) - node(2,face(1,:));
    p1pi(3,:) = node(3,face(i,:)) - node(3,face(1,:));
    flatnode(1,i,:) = Ox(1,:).*p1pi(1,:) + Ox(2,:).*p1pi(2,:) + Ox(3,:).*p1pi(3,:);
    flatnode(2,i,:) = Oy(1,:).*p1pi(1,:) + Oy(2,:).*p1pi(2,:) + Oy(3,:).*p1pi(3,:);
end







