% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

%close all
%clear all
clc

% ---
%%
mur = 2000;

tP = 500e-3;
wP = 500e-3;
cP = [0, -tP/2];
% ---
agap = 4e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [9/10*wP/2, y0];



xmir = +wP/2;
ymir = 0;
k=40;
%%
imagesys = generateimage(c0, I0,xmir, ymir, mur, k);

img = imagesys.imageregion1;
%img.pos
%img.I

%%
nbp = 500;
px  = linspace(+wP/4,+wP/2,nbp);
py  = 2*agap .* ones(1,nbp);
node = [px; py];
induction_mag = calculBregion(c0, I0, xmir, ymir, mur, k, node);
%%
 coeff=(-tP/20);
 pxNoyau  = linspace(+wP/4,+wP/2,nbp);
 pyNoyau = coeff .* ones(1,nbp);
 node_noyau = [pxNoyau; pyNoyau];
 induction_mag_noyau = calculBregion(c0, I0, xmir, ymir, mur, k, node_noyau);







%%
dataANA.c0   = c0;
dataANA.mur  = mur;
dataANA.I0   = I0;
dataANA.tP   = tP;
dataANA.wP   = wP;
dataANA.agap = agap;
dataANA.px = px;
dataANA.py = py;
 dataANA.pxNoyau = pxNoyau;
 dataANA.pyNoyau = pyNoyau;

save('dataANA.mat','dataANA')
%%
figure
subplot(121)
plot(px, (induction_mag.region1(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag.region1(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
title(" Induction magnétique region 1")
%% ---
figure
subplot(121)
plot(px, (induction_mag_noyau.region0(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag_noyau.region0(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
title(" Induction magnétique region 2")
%%
%  figure
%  plot(pxNoyau, vecnorm(induction_mag_noyau.region0), "r-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
%  
%  title(" Induction magnétique region 0 à -tp/2")
% 


