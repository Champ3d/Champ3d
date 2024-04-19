%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = cal_flatnode(obj)

% ---
node      = obj.node;
face      = obj.elem;
% ---
if isempty(face) || isempty(node) || size(node,1) < 3
    obj.flat_node = [];
    return
end
% ---
nvec      = f_chavec(node,face,'defined_on','face');
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
% -------------------------------------------------------------------------
obj.flat_node = flatnode;