% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

%close all
%clear all
clc

% ---
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
B{1} = fB(c0, node, I0);
B{2} = fB(posy, node, alp*I0); % alpha I
B{3} = fB(posx, node, I0/alp); %  I/alpha
B{4} = fB(posxy, node,  I0); %  I
B{5} = fB(c0, node, beta*beta2*I0); % beta'*beta*I
B{6} = fB(posxy, node,  beta*beta2*I0); % beta*beta'I
B{7}=fB(posy, node, alp*beta*beta2*I0); % alp*beta'*beta*I
%%
B_noyau{1}=fB(c0, node, beta*I0);%betaI
B_noyau{2}=fB(posx, node,beta *I0/alp);%betaI/alpha
B_noyau{3}=fB(posxy, node,beta *I0);%betaI
B_noyau{4}=fB(posx, node,alp2*beta *I0);%alpha'*betaI
B_noyau{5}=fB(c0, node, beta2*beta^2*I0);%beta^2*beta'I








%%
figure
Btot = 0;
for i = 1:7
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