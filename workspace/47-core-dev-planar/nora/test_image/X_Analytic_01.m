% ---------------- TEST MULTIPLE IMAGES -----------------------------------
% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

close all
clear all
clc

% ---
mur = 1;
alpha = (mur - 1) / (mur + 1);
tP = 200e-3;
wP = 200e-3;
cP = [0, -tP/2];
% ---
agap = 2e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [9/10*wP/2, y0];
% ---
% ---
nbp = 400;
px  = linspace(-wP/2,+wP/2,nbp);
py  = +agap/2 .* ones(1,nbp);
% ---
dataAN.c0   = c0;
dataAN.mur  = mur;
dataAN.I0   = I0;
dataAN.tP   = tP;
dataAN.wP   = wP;
dataAN.agap = agap;
dataAN.px = px;
dataAN.py = py;

save dataAN dataAN

%%
% dxy = 1e-3;
% xnode = -wP : dxy : wP;
% ynode = -(tP+agap) : dxy : (tP+agap);
% [xnode, ynode] = meshgrid(xnode,ynode);
% node = [xnode(:).'; ynode(:).'];

node = [px; py];

%%
B0 = fB(c0, node, I0);

%%
xmir = +wP/2;
cMx1 = fmirx(c0, xmir);
IMx1 = alpha * I0;
BMx1 = fB(cMx1, node, IMx1);

%%
ymir = 0;
cMy11 = fmiry(c0, ymir);
IMy11 = alpha * I0;
BMy11 = fB(cMy11, node, IMy11);

%%
ymir = 0;
cMy12 = fmiry(cMx1, ymir);
IMy12 = alpha * IMx1;
BMy12 = fB(cMy12, node, IMy12);

%%
% xmir = -wP/2;
% cMx2 = fmirx(c0, xmir);
% IMx2 = alpha * I0;
% BMx2 = fB(cMx2, node, IMx2);
% ymir = 0;
% cMy22 = fmiry(cMx2, ymir);
% IMy22 = alpha * IMx2;
% BMy22 = fB(cMy22, node, IMy22);


%%
% B = B0 + BMx1 + BMx2 + BMy11 + BMy12 + BMy22;
B = B0 + BMx1 + BMy11 + BMy12;

%%
figure
rectangle('Position',[-wP/2,-tP,+wP,+tP]); hold on
plot(c0(1),c0(2),'ro')
quiver(node(1,:),node(2,:), B(1,:), B(2,:)); view(2);
axis equal

%%
figure
plot(px, vecnorm(B), "r-", "LineWidth", 2, 'DisplayName', 'AN'); hold on


