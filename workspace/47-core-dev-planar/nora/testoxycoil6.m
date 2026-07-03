close all
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

coil1 = OxyCoil6("I",1,"imagelevel",1);
coil1.add_turn(turnA11);
coil1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
coil1.setup;
L1a=coil1.getL
