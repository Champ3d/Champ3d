
%close all
clear all
clc

%% Geo parameters
I1 = 1;
I2 = 0;
ri = 100e-3;
ro = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 0.1e-3;
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
turn11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",180,"openo",180,"pole",+1);
turn12 = turn11'; turn12.rotate(180); turn12.pole = +1;
%%
nbp = 200;
xline = linspace(0,+2*ro,nbp);
yline = zeros(size(xline));
% ---
z0 = - (tcoil/2+dfer+tfer/2);
zline = z0 .* ones(size(xline));
node_01 = [xline; yline; zline];
% ---
z0 = + (tcoil/2+agap+tcoil/2+dfer+tfer/2);
zline = z0 .* ones(size(xline));
node_02 = [xline; yline; zline];
%%
dataAN.xline = xline;
dataAN.node_01 = node_01;
dataAN.node_02 = node_02;
save dataAN dataAN;

%%
figure
for ilevel = 5
    coil1 = OxyCoil4("I",I1,"imagelevel",ilevel);
    coil1.add_turn(turn11);
    coil1.add_turn(turn12);
    coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
    coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
    % ---
    coilsystem = OxyCoilSystemb(); 
    coilsystem.add_coil(coil1);
    % ---
    coilsystem.setup;
    A_01 = coilsystem.getanode("node",node_01);
    A_02 = coilsystem.getanode("node",node_02);
    % ---
    plot(xline, A_01(2,:), "Color", f_color(ilevel), 'DisplayName', num2str(ilevel)); hold on
    plot(xline, A_02(2,:), "Color", f_color(ilevel), 'DisplayName', num2str(ilevel)); hold on
end
%%
figure
for ilevel = 5
    coil1 = OxyCoil4("I",I1,"imagelevel",ilevel);
    coil1.add_turn(turn11);
    coil1.add_turn(turn12);
    coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
    coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
    % ---
    coilsystem = OxyCoilSystemb(); 
    coilsystem.add_coil(coil1);
    % ---
    coilsystem.setup;
    B_01 = coilsystem.getbnode("node",node_01);
    B_02 = coilsystem.getbnode("node",node_02);
    % ---
    plot(xline, vecnorm(B_01), "Color", f_color(ilevel), 'DisplayName', num2str(ilevel)); hold on
    plot(xline, vecnorm(B_02), "Color", f_color(ilevel), 'DisplayName', num2str(ilevel)); hold on
end
