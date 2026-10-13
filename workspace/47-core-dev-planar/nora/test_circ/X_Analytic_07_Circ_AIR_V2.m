
% close all
clear all
clc

%% Geo parameters
I1 = 1;
I2 = 0;
rtx = 750e-3/2;
rrx = 750e-3/2;
dmblin = 100e-3;
mu0 = 4*pi*1e-7;
rwire = 5e-3;
agap = 200e-3;
Tx_agap = 10e-3; % distance coil-ferrite
Rx_agap = 10e-3; % distance coil-ferrite
mur = 2000;
% ---
rfertx = rtx + 10e-3; % 50e-3
rferrx = rrx + 10e-3; % 50e-3
tfer = 15e-3;
tcoil = rwire;
% --- save
dataAN.I1 = I1;
dataAN.I2 = I2;
dataAN.rtx  = rtx;
dataAN.rrx  = rrx;
dataAN.rwire = rwire;
dataAN.agap = agap;
dataAN.Tx_agap = Tx_agap;
dataAN.Rx_agap = Rx_agap;
dataAN.mur = mur;
dataAN.rfertx = rfertx;
dataAN.rferrx = rferrx;
dataAN.tfer = tfer;
dataAN.tcoil = tcoil;
dataAN.dmblin = dmblin;
% ---
save dataAN_07 dataAN

%%
% --- bottom coil tx
cen0 = [0, 0];
z0   = -agap/2;
turn1 = OxyTurnT01b("center",cen0,"z",z0,"r",rtx,"rwire",rwire,"pole",+1);
% --- images of tx
d0_eff = tfer;
nbim = 6;
% -------------------------------------------------------------------------
zima = {};
for i = 1:nbim
    if i == 1
        zima{i} = fmirz3d(z0,-(agap/2 + Tx_agap + d0_eff));
    else
        if mod(i,2) == 0
            zima{i} = fmirz3d(zima{i-1},+(agap/2 + Rx_agap + d0_eff));
        else
            zima{i} = fmirz3d(zima{i-1},-(agap/2 + Tx_agap + d0_eff));
        end
    end
end
% -------------------------------------------------------------------------
zimb = {};
for i = 1:nbim
    if i == 1
        zimb{i} = fmirz3d(z0,+(agap/2 + Rx_agap + d0_eff));
    else
        if mod(i,2) == 0
            zimb{i} = fmirz3d(zimb{i-1},-(agap/2 + Tx_agap + d0_eff));
        else
            zimb{i} = fmirz3d(zimb{i-1},+(agap/2 + Rx_agap + d0_eff));
        end
    end
end
% -------------------------------------------------------------------------
imturn1a = {};
for i = 1:nbim
    imturn1a{i} = OxyTurnT01b("center",cen0,"z",zima{i},"r",rtx,"rwire",rwire,"pole",+1);
end
% -------------------------------------------------------------------------
imturn1b = {};
for i = 1:nbim
    imturn1b{i} = OxyTurnT01b("center",cen0,"z",zimb{i},"r",rtx,"rwire",rwire,"pole",+1);
end
% -------------------------------------------------------------------------
r1 = fmirr3d(rtx,rfertx + dmblin);
imturn2a = {};
for i = 1%:nbim
    imturn2a{i} =OxyTurnT01b("center",cen0,"z",zima{i},"r",r1,"rwire",rwire,"pole",+1);
end
% -------------------------------------------------------------------------
r2 = fmirr3d(rtx,rferrx + dmblin);
imturn2b = {};
for i = 1%:nbim
    imturn2b{i} =OxyTurnT01b("center",cen0,"z",zimb{i},"r",r2,"rwire",rwire,"pole",+1);
end
% -------------------------------------------------------------------------
r1 = fmirr3d(rtx,rfertx + dmblin);
imturn2c = {};
% for i = 1%:nbim
%     imturn2c{i} =OxyTurnT01b("center",cen0,"z",z0,"r",r1,"rwire",rwire,"pole",+1);
% end
% -------------------------------------------------------------------------
% --- top coil rx
turn2 = OxyTurnT01b("center",[0 0],"z",agap,"r",rrx,"rwire",rwire,"pole",+1);

%% Check 01
% figure
% turn1.plot("color","m"); hold on
% for i = 1:length(imturn1)
%     imturn1{i}.plot("color",f_color(i));
% end
%turn2.plot;

%%
nbp = 200;
xline = linspace(0,rtx-rwire,nbp);
yline = zeros(size(xline));
% ---
z_ = -agap/2;
zline = z_ .* ones(size(xline));
node_01 = [xline; yline; zline];
% ---
z_ = +agap/2;
zline = z_ .* ones(size(xline));
node_02 = [xline; yline; zline];

%%
dataAN.xline = xline;
dataAN.node_01 = node_01;
dataAN.node_02 = node_02;
save dataAN dataAN;

%%
coil1 = OxyCoil5("I",I1);
coil1.add_turn(turn1);
% ---
alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;
alppp = - alpha;
betpp = 1 + alppp;
% ---
facI1 = 1;
imcoil1a = {};
for i = 1:length(imturn1a)
    imcoil1a{i} = OxyCoil5("I",alpha^i * I1 * facI1); imcoil1a{i}.add_turn(imturn1a{i});
end
% ---
imcoil1b = {};
for i = 1:length(imturn1b)
    imcoil1b{i} = OxyCoil5("I",alpha^i * I1 * facI1); imcoil1b{i}.add_turn(imturn1b{i});
end
% ---
facI2 = 1;
imcoil2a = {};
for i = 1:length(imturn2a)
    imcoil2a{i} = OxyCoil5("I",alpha * alppp * I1 * facI2); imcoil2a{i}.add_turn(imturn2a{i});
end
% ---
imcoil2b = {};
for i = 1:length(imturn2b)
    imcoil2b{i} = OxyCoil5("I",alpha * alppp * I1 * facI2); imcoil2b{i}.add_turn(imturn2b{i});
end
% ---
imcoil2c = {};
for i = 1:length(imturn2c)
    imcoil2c{i} = OxyCoil5("I",alppp * I1 * facI2); imcoil2c{i}.add_turn(imturn2c{i});
end

% ---
coil2 = OxyCoil5("I",I2);
coil2.add_turn(turn2);


%% ---
coilsystem = OxyCoilSystemb(); 
coilsystem.add_coil(coil1);
coilsystem.add_coil(coil2);

for i = 1:length(imcoil1a)
    coilsystem.add_coil(imcoil1a{i});
end
for i = 1:length(imcoil1b)
    coilsystem.add_coil(imcoil1b{i});
end
for i = 1:length(imcoil2a)
    coilsystem.add_coil(imcoil2a{i});
end
for i = 1:length(imcoil2b)
    coilsystem.add_coil(imcoil2b{i});
end
for i = 1:length(imcoil2c)
    coilsystem.add_coil(imcoil2c{i});
end

%%
A_01 = coilsystem.getanode("node",node_01);
A_02 = coilsystem.getanode("node",node_02);
% ---
figure
plot(xline, A_01(2,:), "Color", 'b', 'DisplayName', 'A - AN'); hold on
plot(xline, A_02(2,:), "Color", 'b', 'DisplayName', 'A - AN'); hold on

%%
B_01 = coilsystem.getbnode("node",node_01);
B_02 = coilsystem.getbnode("node",node_02);
% ---
figure
subplot(121)
plot(xline, B_01(3,:), "Color", 'b', 'DisplayName', num2str(1)); hold on
subplot(122)
plot(xline, B_02(3,:), "Color", 'b', 'DisplayName', num2str(2)); hold on

%%
B_01 = coilsystem.getbnode("node",node_01);
B_02 = coilsystem.getbnode("node",node_02);
% ---
figure
subplot(121)
plot(xline, B_01(1,:), "Color", f_color(1), 'DisplayName', num2str(1)); hold on
subplot(122)
plot(xline, B_01(3,:), "Color", f_color(2), 'DisplayName', num2str(2)); hold on
figure
subplot(121)
plot(xline, B_02(1,:), "Color", f_color(1), 'DisplayName', num2str(1)); hold on
subplot(122)
plot(xline, B_02(3,:), "Color", f_color(2), 'DisplayName', num2str(2)); hold on
