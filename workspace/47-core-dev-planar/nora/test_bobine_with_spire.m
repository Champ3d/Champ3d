close all
clear all
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
nspire=3;
nbphase=2;
distance=wcoil+1e-6;
distance1=wcoil+1e-6;
%%
turnA11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",90,"openo",90,"pole",+1);

turnA21 = turnA11';
turnA21.pole = -1;
turnA21.rotate(180);



spiresA11(1) = turnA11;         
namesA11{1}  = 'A11';           
%%%%%%%%%%%%%%%%%%%%%%%%%%% phase A pole 1 spire i%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2:nspire
    spiresA11(i) = spiresA11(i-1)'; 
    
    namesA11{i} = sprintf('turnA1%d', i);  
 spiresA11(i).scale(distance, distance1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spiresA21(1) = turnA21;         
namesA21{1}  = 'A21';   
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  phase A pole 1 spire i%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2:nspire
    spiresA21(i) = spiresA21(i-1)'; 
    namesA21{i} = sprintf('turnA2%d', i);  
   spiresA21(i).scale(distance, distance1);
end



figure; clf; hold on

cmap = lines(nspire);                 
for i = 1:nspire
    spiresA11(i).plot("color", cmap(i,:));
    spiresA21(i).plot("color", cmap(i,:));
end

view(2)





coil11 = OxyCoil4("I",1,"imagelevel",1);
for i=1:nspire
coil11.add_turn(spiresA11(i));
coil11.add_turn(spiresA21(i));
end
coil11.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coil11.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
coil11.setup;
L1a=coil11.getL



coilarray = {};
% --- transmitter
for i = 1:nbphase
    ccopy = coil11';
    ccopy.rotate((i-1)*360/(2*nbphase));
    ccopy.setup;
    coil2=ccopy';
    % ---
    coilarray{end+1} = ccopy;
end
M=coil11.getM(coil2)

coil_system = OxyCoilSystem(); 
coil_system.add_coil(coilarray);

coil_system.plot;

L = 1e6*coil_system.getL