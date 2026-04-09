% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

close all
clear all
clc

% ---
%%
mur = 2000;

tP = 15e-3;
wP = 750e-3;
cP = [0, -tP/2];
% ---
distance_nf=10e-3;
agap = 200e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [x0, y0];


z1secondaire=agap+distance_nf;
z1primaire=distance_nf;

imagelevel=2;


%%
nbp = 300;
px  = linspace(-wP/4,+wP/2,nbp);
py  = agap/2.*ones(1,nbp);%agap/2 .* ones(1,nbp);
node = [px; py];
induction_mag = calculBregion(c0,I0,z1primaire,z1secondaire,tP,mur,imagelevel,node);
%%
 coeff=-10e-3;
   pxNoyau = linspace(-wP/4,+wP/2,nbp);
 pyNoyau = coeff .* ones(1,nbp);
 node_noyau = [pxNoyau; pyNoyau];
induction_mag_noyau = calculBregion(c0,I0,z1primaire,z1secondaire,tP,mur,imagelevel, node_noyau);







%%
dataAN.c0   = c0;
dataAN.mur  = mur;
dataAN.I0   = I0;
dataAN.tP   = tP;
dataAN.wP   = wP;
dataAN.agap = agap;
dataAN.px = px;
dataAN.py = py;
dataAN.z1primaire=z1primaire;
dataAN.z1secondaire=z1secondaire;
dataAN.distance_nf=distance_nf;
 dataAN.pxNoyau = pxNoyau;
 dataAN.pyNoyau = pyNoyau;

save('dataAN.mat','dataAN')

%%
figure(1);hold on;
sgtitle(" Induction magnétique region 3")
subplot(121)
plot(px, (induction_mag.region3(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag.region3(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on

%% ---
figure(2);hold on;
sgtitle(" Induction magnétique region 2")
subplot(121)
plot(px, (induction_mag_noyau.region2(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag_noyau.region2(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on



