% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

close all
clear all
clc

% ---
%%

mur = 2000;

tP = 1000e-3;
wP = 1000e-3;
cP = [0, -tP/2];
% ---
agap = 4e-3;
% ---
I0 = 1;
x0 = 0;
y0 = agap;
c0 = [wP/2-5e-3, y0];



xmir = +wP/2;
ymir = 0;
k=40;


posx  = fmirx(c0,xmir);
posy  = fmiry(c0,ymir);
posxy = fmiry(posx,ymir);

%%
nbp = 500;
px  = linspace(+wP/4,+wP/2,nbp);
py  = agap/2.*ones(1,nbp);%agap/2 .* ones(1,nbp);
node = [px; py];

% ---
alp  = (mur - 1) / (mur + 1);
alp2 = - alp;
beta=1+alp;
beta2=1-alp;
B{1} = fB([0.495 , 0.004], node, I0);
B{2} = fB([0.495 , -0.004], node, alp*I0); % alpha I
B{3} = fB([0.505 , -0.004], node, alp*alp2*I0); % alpha alpha' I
B{4} = fB([0.505 , 0.004], node,  alp2*I0); % alpha' I
%B{5} = fB([0.505 , -0.004], node, I0); % I
%B{6} = fB([0.505 , 0.004], node,  I0/alp); % I

%%
figure(1)
sgtitle(" Induction magnétique region 1")
Btot = 0;
for i = 1:4
    Btot = Btot + B{i};
    subplot(121);
    plot(px, Btot(1,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    subplot(122);
    plot(px, Btot(2,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
end


subplot(121);
legend show

subplot(122);
legend show


%%
pxNoyau= linspace(+wP/4,+wP/2,nbp);
pyNoyau=-5e-3.*ones(1,nbp);

node = [pxNoyau; pyNoyau];


B{1} = fB(c0, node, beta*I0);
B{2} = fB(posx, node, alp2*beta*I0); % alpha'*beta I



figure(2)
sgtitle(" Induction magnétique region 0")
Btot = 0;
for i = 1:2
    Btot = Btot + B{i};
    subplot(121);
    plot(pxNoyau, Btot(1,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    subplot(122);
    plot(pxNoyau, Btot(2,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
end
subplot(121);
legend show

subplot(122);
legend show


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