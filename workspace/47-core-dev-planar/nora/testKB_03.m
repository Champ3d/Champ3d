%% Geo parameters
close all
clear all
clc

%%
I  = 1;
ri = 100e-3;
ro = 150e-3; %750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1;
% ---
tfer = 10e-3;
tcoil = 5e-3;
%%

turnA11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",120,"openo",120,"pole",+1);

% ---
turnA21 = turnA11';
turnA21.pole = -1;
turnA21.rotate(180);
turnA11.setup;

return

%% ---
dx = 0.5e-3;
P1 = [ri * cosd(-60), ri * sind(-60), 0];
P2 = [ro * cosd(-60), ro * sind(-60), 0];
% ---
nbpP = 100;
% --- nodes P1-P2
node = zeros(3,nbpP);
node(1,:) = linspace(P1(1) + dx,P2(1) + dx,nbpP);
node(2,:) = linspace(P1(2) + dx,P2(2) + dx,nbpP);
node(3,:) = linspace(P1(3) + dx,P2(3) + dx,nbpP);
len = vecnorm(node - node(:,1));
% ---
iwire = 1;
A = turnA11.wire{iwire}.getanode("node",node,"I",1);

% 
figure
turnA11.plot; hold on
plot3(node(1,:),node(2,:),node(3,:),'ro');

%
figure
f_quiver(node,A); hold on

%
figure
plot(len,vecnorm(A));

%% ---
dx = 0.1e-3;
P1 = [ri * cosd(+60), ri * sind(+60), 0];
P2 = [ro * cosd(+60), ro * sind(+60), 0];
% ---
nbpP = 100;
% --- nodes P1-P2
node = zeros(3,nbpP);
node(1,:) = linspace(P1(1) + dx,P2(1) + dx,nbpP);
node(2,:) = linspace(P1(2) + dx,P2(2) + dx,nbpP);
node(3,:) = linspace(P1(3) + dx,P2(3) + dx,nbpP);
len = vecnorm(node - node(:,1));
% ---
iwire = 2;
A = turnA11.wire{iwire}.getanode("node",node,"I",1);

%
figure
f_quiver(node,A); hold on

%
figure
plot(len,vecnorm(A));

%% ---
dx = 0.1e-3;
% ---
nbpP = 100;
da = linspace(-60,+60,nbpP);
% --- nodes P1-P2
node = zeros(3,nbpP);
for i = 1:2
    node(1,:) = (ri + dx) .* cosd(da);
    node(2,:) = (ri + dx) .* sind(da);
end
len = vecnorm(node - node(:,1));
% ---
A = 0;
for iwire = 3:6
    A = A + turnA11.wire{iwire}.getanode("node",node,"I",1);
end
%
figure
f_quiver(node,A); hold on

%
figure
plot(da,vecnorm(A));

%% ---
dx = 0.1e-3;
% ---
nbpP = 100;
da = linspace(-60,+60,nbpP);
% --- nodes P1-P2
node = zeros(3,nbpP);
for i = 1:2
    node(1,:) = (ro - dx) .* cosd(da);
    node(2,:) = (ro - dx) .* sind(da);
end
len = vecnorm(node - node(:,1));
% ---
A = 0;
for iwire = 3:6
    A = A + turnA11.wire{iwire}.getanode("node",node,"I",1);
end
%
figure
f_quiver(node,A); hold on

%
figure
plot(da,vecnorm(A));







