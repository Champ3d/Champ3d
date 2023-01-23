function [p2d,t2d]=f_reorg2d(p2d,t2d)
% F_REORG2D returns a 2D mesh with element of same orientation corrected
% using usual convention
%--------------------------------------------------------------------------
% [p2d,t2d]=F_REORG2D(p2d,t2d);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% V1 = vector: node_1 -> node_2
% V2 = vector: node_1 -> node_3

sizet2d = size(t2d,2);

V1 = zeros(3,sizet2d);
V2 = zeros(3,sizet2d);

V1(1,:) = p2d(1,t2d(2,:))-p2d(1,t2d(1,:));
V1(2,:) = p2d(2,t2d(2,:))-p2d(2,t2d(1,:));
V1(3,:) = zeros(1,length(V1(2,:)));

V2(1,:) = p2d(1,t2d(3,:))-p2d(1,t2d(1,:));
V2(2,:) = p2d(2,t2d(3,:))-p2d(2,t2d(1,:));
V2(3,:) = zeros(1,length(V2(2,:)));

%----- normal vector n
V1xV2(3,:) = V1(1,:).*V2(2,:)-V2(1,:).*V1(2,:);

%----- n_z
n_z(1,:) = sign(V1xV2(3,:));

% check and correct
iBad = find(n_z < 0);
n2 = t2d(2,iBad);
n3 = t2d(3,iBad);
t2d(2,iBad) = n3;
t2d(3,iBad) = n2;






