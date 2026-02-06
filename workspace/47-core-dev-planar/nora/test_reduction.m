close all
clear all
I = 1;
ri=100e-3;
r = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1;
% ---
tfer = 10e-3;
tcoil = 5e-3;
%%

rng('shuffle')

v   = sort(randi([10,180],1,2));
dir = randi([10,180]);
cen = 10 * rand(1,2);

v = sort(randi([10,180],1,2));
a = v(1);
b = v(2);
dir=randi([10,180]);
cen=10 * rand(1,2);




turnA11 = OxyTurnT00b("center",cen,"dir",dir,"ri",ri,"ro",r,"rwire",wcoil,"z",0,"openi",a,"openo",b,"pole",+1);

% ---
turnA21 = turnA11';
turnA21.pole = -1;
turnA21.rotate(180);
figure
turnA11.plot("color","r"); hold on
%plot3(turnA11.dom.nodebord (1,:),turnA11.dom.nodebord (2,:),turnA11.dom.nodebord (3,:),'o');hold on
plot3(turnA11.dom.node(1,:),turnA11.dom.node(2,:),turnA11.dom.node(3,:),'*');hold on
%quiver(turnA11.dom.node,turnA11.dom.len);
view(2)