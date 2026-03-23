% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

%close all
%clear all
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
c0 = [wP/2-50e-3, y0];

xmir = +wP/2;
ymir = 0;
k=40;

%%
nbp = 500;
px  = linspace(+wP/4,+wP/2,nbp);
py  = agap/2.*ones(1,nbp);%agap/2 .* ones(1,nbp);
node = [px; py];

% ---
alp  = (mur - 1) / (mur + 1);
alp2 = - alp;

B{1} = fB([0.495 , 0.004], node, I0);
B{2} = fB([0.495 , -0.004], node, alp*I0); % alpha I
B{3} = fB([0.505 , -0.004], node, alp*alp2*I0); % alpha alpha' I
B{4} = fB([0.505 , 0.004], node, -alp2*I0); % alpha' I
B{5} = fB([0.505 , -0.004], node, -I0); % I
B{6} = fB([0.505 , 0.004], node, -I0/alp); % I

%%
figure
Btot = 0;
for i = 1:6
    Btot = Btot + B{i};
    subplot(121);
    plot(px, Btot(1,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    subplot(122);
    plot(px, Btot(2,:), f_color(i), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
end