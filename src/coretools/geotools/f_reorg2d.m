function [node,elem]=f_reorg2d(node,elem)
% F_REORG2D returns a 2D mesh with corrected orientation
% using usual convention
%--------------------------------------------------------------------------
% [node,elem] = F_REORG2D(node,elem)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% V1 = vector: node_1 -> node_2
% V2 = vector: node_1 -> node_3

sizet2d = size(elem,2);

V1 = zeros(3,sizet2d);
V2 = zeros(3,sizet2d);

V1(1,:) = node(1,elem(2,:))-node(1,elem(1,:));
V1(2,:) = node(2,elem(2,:))-node(2,elem(1,:));
V1(3,:) = zeros(1,length(V1(2,:)));

V2(1,:) = node(1,elem(3,:))-node(1,elem(1,:));
V2(2,:) = node(2,elem(3,:))-node(2,elem(1,:));
V2(3,:) = zeros(1,length(V2(2,:)));

%----- normal vector n
V1xV2(3,:) = V1(1,:).*V2(2,:)-V2(1,:).*V1(2,:);

%----- n_z
n_z(1,:) = sign(V1xV2(3,:));

% check and correct
iBad = find(n_z < 0);
n2 = elem(2,iBad);
n3 = elem(3,iBad);
elem(2,iBad) = n3;
elem(3,iBad) = n2;






