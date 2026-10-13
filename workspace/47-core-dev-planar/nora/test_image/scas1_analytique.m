% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

%close all
%clear all
clc

% ---
%%
mur = 2000;

tP = 5000e-3;
wP = 5000e-3;
cP = [0, -tP/2];
% ---
agap = 4e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [0, y0];
alpha=(mur-1)/(mur+1);


xmir = +wP/2;
ymir = 0;



%%
nbp = 500;
px  = linspace(+wP/4,+wP/2,nbp);
py  = agap/2.*ones(1,nbp);%agap/2 .* ones(1,nbp);
node = [px; py];
induction_mag = fB(fmiry(c0,ymir),node,alpha*I0)+fB(c0,node,I0);

%%
figure
sgtitle(" Induction magnétique region 1 à agap/2")
subplot(121)
plot(px, (induction_mag(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on




%%
 coeff=-5e-3;
 pxNoyau  = linspace(+wP/4,+wP/2,nbp);
 pyNoyau = coeff .* ones(1,nbp);
 node_noyau = [pxNoyau; pyNoyau];

 induction_mag_noyau = fB(c0, node_noyau,(1+alpha)*I0);
%% ---
figure
sgtitle(" Induction magnétique region 0 à -tp/20")
subplot(121)
plot(px, (induction_mag_noyau(1,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on
subplot(122)
plot(px, (induction_mag_noyau(2,:)), "b-", "LineWidth", 2, 'DisplayName', 'AN'); hold on





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




