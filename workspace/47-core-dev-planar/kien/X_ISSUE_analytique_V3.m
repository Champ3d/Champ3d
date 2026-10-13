
close all
clear all
clc

%% Geo parameters
I1 = 1;
I2 = 0;
ri = 100e-3;
ro = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
% ---
tfer = 10e-3;
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
turn11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",360,"openo",360,"pole",+1);
% ---
coil1 = OxyCoil4("I",I1,"imagelevel",3);
coil1.add_turn(turn11);
coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
%coil1.setup;
% ---
coilsystem = OxyCoilSystemb(); 
coilsystem.add_coil(coil1);
%%
figure
coilsystem.plot;

%%
nbp = 200;
xline = linspace(0,+2*ro,nbp);
yline = zeros(size(xline));
% ---
z0 = 0;
zline = z0 .* ones(size(xline));
node_01 = [xline; yline; zline];
% ---
z0 = tcoil/2+agap+tcoil/2;
zline = z0 .* ones(size(xline));
node_02 = [xline; yline; zline];

%%
A_01 = coilsystem.getanode("node",node_01);
A_02 = coilsystem.getanode("node",node_02);

%%
% A_01 = 0;
% A_01 = A_01 + turn11.getanode("node",node_01,"I",I1);
% A_01 = A_01 + turn12.getanode("node",node_01,"I",I1);
% A_01 = A_01 + turn21.getanode("node",node_01,"I",I2);
% A_01 = A_01 + turn22.getanode("node",node_01,"I",I2);
% 
% A_02 = 0;
% A_02 = A_02 + turn11.getanode("node",node_02,"I",I1);
% A_02 = A_02 + turn12.getanode("node",node_02,"I",I1);
% A_02 = A_02 + turn21.getanode("node",node_02,"I",I2);
% A_02 = A_02 + turn22.getanode("node",node_02,"I",I2);
%%

figure
f_quiver(node_01, A_01); hold on
f_quiver(node_02, A_02)

%%
dataAN.xline = xline;
dataAN.node_01 = node_01;
dataAN.node_02 = node_02;
dataAN.A_01 = A_01;
dataAN.A_02 = A_02;
save dataAN dataAN;

%%

figure
plot(xline, A_01(2,:), 'b', 'DisplayName', 'A at z coil1'); hold on
plot(xline, A_02(2,:), 'r', 'DisplayName', 'A at z coil2'); hold on
return

