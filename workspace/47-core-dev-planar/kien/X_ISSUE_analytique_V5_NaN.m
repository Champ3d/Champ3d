
close all
clear all
clc

%% Geo parameters
I1 = 1;
I2 = 0;
ri = 100e-3;
ro = 750e-3/2;
openi = 100;
openo = 100;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
% ---
tfer = 20e-3;
tcoil = wcoil;
% --- save
dataAN.I1 = I1;
dataAN.I2 = I2;
dataAN.ri = ri;
dataAN.ro = ro;
dataAN.wcoil = wcoil;
dataAN.agap = agap;
dataAN.dfer = dfer;
dataAN.mur = mur;
dataAN.tfer = tfer;
dataAN.tcoil = tcoil;
%%
% --- bottom coil
turn11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",openi,"openo",openo,"pole",+1);
turn12 = turn11';
turn12.rotate(120);
turn13 = turn11';
turn13.rotate(240);

%%

% figure
% tplot = turn11;
% tplot.setup;
% tplot.plot; hold on
% plot3(tplot.dom.mean.node(1,:),tplot.dom.mean.node(2,:),tplot.dom.mean.node(3,:),'ro');
% plot3(tplot.dom.interior.node(1,:),tplot.dom.interior.node(2,:),tplot.dom.interior.node(3,:),'bx');
% % ---
% tplot = turn12;
% tplot.setup;
% tplot.plot; hold on
% plot3(tplot.dom.mean.node(1,:),tplot.dom.mean.node(2,:),tplot.dom.mean.node(3,:),'ro');
% plot3(tplot.dom.interior.node(1,:),tplot.dom.interior.node(2,:),tplot.dom.interior.node(3,:),'bx');
% 
% return

%%
turn11.setup;
turn12.setup;
node_01 = turn12.dom.mean.node;
node_02 = turn12.dom.interior.node;
A_01 = turn11.getanode("node",node_01);
A_02 = turn11.getanode("node",node_02);
% ---
figure
f_quiver(node_01,A_01);
figure
f_quiver(node_02,A_02);
% ---
%%
ilevel = 1;
% ---
coil1 = OxyCoil4("I",I1,"imagelevel",ilevel);
coil1.add_turn(turn11);
coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
% ---
coil2 = OxyCoil4("I",I1,"imagelevel",ilevel);
coil2.add_turn(turn12);
coil2.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil2.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
% ---
coil3 = OxyCoil4("I",I1,"imagelevel",ilevel);
coil3.add_turn(turn13);
coil3.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil3.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
% ---
coilsystem = OxyCoilSystemb(); 
coilsystem.add_coil(coil1);
coilsystem.add_coil(coil2);
coilsystem.add_coil(coil3);
% ---
figure
coilsystem.plot
LuH = coilsystem.getL .* 1e6


