% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

%close all
%clear all
clc

% ---
%%
% ---
dmax = 100e3;
% --- plate
mur = 2000;
tP = 15e-3;
wP = 750e-3;
cP = [0, -tP/2];
dP = 200e-3; % dist plate-plate
% ---
agap = 10e-3;
% --- coil
I0 = 1;
x0 = 0;
y0 = agap;
d0 = 5e-3;
c0 = [wP/2-d0, y0];
% --- save
dataAN.dmax = dmax;
dataAN.d0   = d0;
dataAN.c0   = c0;
dataAN.mur  = mur;
dataAN.I0   = I0;
dataAN.tP   = tP;
dataAN.wP   = wP;
dataAN.dP   = dP;
dataAN.agap = agap;
% ------
nbp = 2000;
px  = linspace(-wP/2,+wP/2,nbp);
% -
% py = 0.*ones(1,nbp);
py  = 1/2*agap.*ones(1,nbp);
% py  = (dP-agap/2).*ones(1,nbp);
% py  = (agap-1e-6).*ones(1,nbp);
% py  = 2*agap.*ones(1,nbp);
% py  = 20*agap.*ones(1,nbp);
% py  = -tP/2.*ones(1,nbp);
% -
node = [px; py];
% ------
dataAN.px = px;
dataAN.py = py;
save dataAN_06 dataAN
%%
alpha  = (mur - 1) / (mur + 1);
beta = 1 + alpha;
alppp = - alpha;
betpp = 1 + alppp;
Batotal  = {};
Bftotal  = {};
%% ------------------------------------------------------------------------

%     AIR

% -------------------------------------------------------------------------
%% --- Formular 1
clear Ba
Ba{1} = fB([c0(1)      , c0(2)], node, I0);     % I
% --- two alpha I
Ba{2} = fB([c0(1)      , c0(2)-2*agap], node, alpha*I0); % alpha I
Ba{3} = fB([c0(1)      , c0(2)+2*(dP-agap)], node, alpha*I0); % alpha I
% --- images of two alpha I
Ba{4} = fB([c0(1)      , c0(2)-2*agap+2*(agap+dP)], node, alpha*alpha*I0); % alpha alpha I
Ba{5} = fB([c0(1)      , c0(2)+2*(dP-agap)-2*(agap+dP)], node, alpha*alpha*I0); % alpha alpha I
% --- 2 sides plate bottom
Ba{6} = fB([c0(1)+2*d0 , c0(2)-2*agap], node, alpha*alppp*I0); % alpha alpha' I
Ba{7} = fB([c0(1)-2*(wP-d0), c0(2)-2*agap], node, alpha*alppp*I0); % alpha alpha' I
% --- 2 sides plate top
Ba{8} = fB([c0(1)+2*d0 , c0(2)+2*(dP-agap)], node, alpha*alppp*I0); % alpha alpha' I
Ba{9} = fB([c0(1)-2*(wP-d0), c0(2)+2*(dP-agap)], node, alpha*alppp*I0); % alpha alpha' I
% ---
Batotal{1} = 0;
for i = 1:length(Ba)
    Batotal{1} = Batotal{1} + Ba{i};
end
%% --- Formular 2
clear Ba
Ba{1} = fB([c0(1)      , c0(2)], node, I0);     % I
% --- two alpha I
Ba{2} = fB([c0(1)      , c0(2)-2*agap], node, alpha*I0); % alpha I
Ba{3} = fB([c0(1)      , c0(2)+2*(dP-agap)], node, alpha*I0); % alpha I
% --- images of two alpha I
Ba{4} = 0;%fB([c0(1)      , c0(2)-2*agap+2*(agap+dP)], node, alpha*alpha*I0); % alpha alpha I
Ba{5} = 0;%fB([c0(1)      , c0(2)+2*(dP-agap)-2*(agap+dP)], node, alpha*alpha*I0); % alpha alpha I
% --- 2 sides plate bottom
Ba{6} = fB([c0(1)+2*d0 , c0(2)-2*agap], node, alpha*alppp*I0); % alpha alpha' I
Ba{7} = fB([c0(1)-2*(wP-d0), c0(2)-2*agap], node, alpha*alppp*I0); % alpha alpha' I
% --- 2 sides plate top
Ba{8} = fB([c0(1)+2*d0 , c0(2)+2*(dP-agap)], node, alpha*alppp*I0); % alpha alpha' I
Ba{9} = fB([c0(1)-2*(wP-d0), c0(2)+2*(dP-agap)], node, alpha*alppp*I0); % alpha alpha' I
% ---
Batotal{2} = 0;
for i = 1:length(Ba)
    Batotal{2} = Batotal{2} + Ba{i};
end

%% ------------------------------------------------------------------------

%     FER

% -------------------------------------------------------------------------

%% --- Formular 1
clear Bf
Bf{1} = fB([c0(1)      , c0(2)], node, beta*I0);     % I
% ---
Bftotal{1} = 0;
for i = 1:length(Bf)
    Bftotal{1} = Bftotal{1} + Bf{i};
end

%% --- Formular 2
clear Bf
Bf{1} = fB([c0(1)      , c0(2)], node, beta*I0);     % I
Bf{2} = fB([c0(1)+2*d0 , c0(2)], node, alppp*beta*I0); % alpha' beta I
% ---
Bftotal{2} = 0;
for i = 1:length(Bf)
    Bftotal{2} = Bftotal{2} + Bf{i};
end

%% --- Formular 3
clear Bf
Bf{1} = fB([c0(1)      , c0(2)], node, beta*I0);     % I
Bf{2} = fB([c0(1)+2*d0 , c0(2)], node, alppp*beta*I0); % alpha' beta I
Bf{3} = fB([c0(1) , c0(2)-2*(agap+tP)], node, alppp*beta*I0); % beta I
% ---
Bftotal{3} = 0;
for i = 1:length(Bf)
    Bftotal{3} = Bftotal{3} + Bf{i};
end

%% --- Formular 4
clear Bf
Bf{1} = fB([c0(1)      , c0(2)], node, beta*I0);     % I
Bf{2} = fB([c0(1)+2*d0 , c0(2)], node, alppp*beta*I0); % alpha' beta I
Bf{3} = fB([c0(1) , c0(2)-2*(agap+tP)], node, alppp*beta*I0); % beta I
Bf{4} = fB([c0(1)+2*d0-3*d0/4, c0(2)], node, -alppp*beta*I0); % alpha' beta I
% ---
Bftotal{4} = 0;
for i = 1:length(Bf)
    Bftotal{4} = Bftotal{4} + Bf{i};
end

%% --- Formular 5
clear Bf
Bf{1} = fB([c0(1)      , c0(2)], node, beta*I0);     % I
Bf{2} = fB([c0(1)+2*d0 , c0(2)], node, alppp*beta*I0); % alpha' beta I
Bf{3} = fB([c0(1) , c0(2)-2*(agap+tP)], node, alppp*beta*I0); % beta I
Bf{4} = fB([c0(1)+2*d0-3*d0/4, c0(2)-2*agap], node, -beta*I0); % beta I
% ---
Bftotal{5} = 0;
for i = 1:length(Bf)
    Bftotal{5} = Bftotal{5} + Bf{i};
end
%% --- Formular 6
clear Bf
Bf{1} = fB([c0(1) , c0(2)], node, I0);     % I
Bf{2} = fB([c0(1) , c0(2)-2*(agap+tP/2)], node, -I0); % alpha' beta I
% ---
Bftotal{6} = 0;
for i = 1:length(Bf)
    Bftotal{6} = Bftotal{6} + Bf{i};
end


%%
figure; 
nc = length(Batotal);
for i = 1:length(Batotal)
    Ba = Batotal{i};
    subplot(121); title('Bx - AIR');
    plot(px, Ba(1,:), 'Color', [0 i i]./(nc+1), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    text(px(end),Ba(1,end),num2str(i),'BackgroundColor','w');
    subplot(122); title('By - AIR');
    plot(px, Ba(2,:), 'Color', [0 i i]./(nc+1), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    text(px(end),Ba(2,end),num2str(i),'BackgroundColor','w');
end
%%
figure;
nc = length(Bftotal);
for i = 1:length(Bftotal)
    Bf = Bftotal{i};
    subplot(121); title('Bx - FER');
    plot(px, Bf(1,:), 'Color', [0 i i]./(nc+1), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    text(px(end),Bf(1,end),num2str(i),'BackgroundColor','w');
    subplot(122); title('By - FER');
    plot(px, Bf(2,:), 'Color', [0 i i]./(nc+1), "LineWidth", 2, 'DisplayName', num2str(i)); hold on
    text(px(end),Bf(2,end),num2str(i),'BackgroundColor','w');
end

%%
figure
rectangle('Position',[-wP/2,-tP,+wP,+tP]); hold on
rectangle('Position',[-wP/2,-tP+tP+dP,+wP,+tP]); hold on
plot(c0(1),c0(2),'ro')
quiver(node(1,:),node(2,:), Ba(1,:), Ba(2,:)); view(2);
axis equal