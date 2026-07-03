%% Geo parameters
close all

% valeur reference avec mu=1000 2.1306
% valeur de reference avec mu=1 1.3084  


I = 1;
ri =100e-3;
ro = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
% ---
tfer = 10e-3;
tcoil = 5e-3;
%%

turnA11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",120,"openo",120,"pole",+1);

% ---
turnA21 = turnA11';
turnA21.pole = -1;
turnA21.rotate(180);


figure
turnA11.plot("color","r"); hold on
plot3(turnA11.dom.node(1,:),turnA11.dom.node(2,:),turnA11.dom.node(3,:),'o');hold on

f_quiver(turnA11.dom.node,turnA11.dom.len);




figure
turnA11.plot("color","r"); hold on
A=turnA11.getanode("node",turnA11.dom.node,"I",1);
f_quiver(turnA11.dom.node,A);
title("A");
%view(2)


%view(2)

coil1 = OxyCoil4("I",1,"imagelevel",1);
coil1.add_turn(turnA11);
coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
coil1.setup;
L1a=coil1.getL

% valeur reference avec mu=1000 2.1306
% valeur de reference avec mu=1 1.3084

%%
figure
turnA11.plot("color","r"); hold on
plot3(turnA11.dom.node(1,:),turnA11.dom.node(2,:),turnA11.dom.node(3,:),'ro');
%%
figure
turnA11.plot("color","r"); hold on
f_quiver(turnA11.dom.node,turnA11.dom.len);
%%
figure
turnA11.plot("color","r"); hold on
f_quiver(turnA11.dom.node,turnA11.A);

