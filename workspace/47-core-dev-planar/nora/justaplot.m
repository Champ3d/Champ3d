close all;
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
epsilon=20;

nspire=1;
nbphase=3;
distance=wcoil+1e-8;
distance1=wcoil+1e-8;


turn11 = OxyTurnT01b("center",[0 0],"z",0,"r",ri+ro,"pole",+1,"rwire",wcoil);

spires11(1) = turn11;         
namest11{1}  = 't11';           
%%%%%%%%%%%%%%%%%%%%%%%%%%% phase A pole 1 spire i%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2:nspire
    spires11(i) = spires11(i-1)'; 
    names11{i} = sprintf('turnt1%d', i);  
    spires11(i).scale(distance, distance1);
end


coilt1 = OxyCoil4("I",1,"imagelevel",1);
for i=1:nspire
coilt1.add_turn(spires11(i));

end
coilt1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coilt1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
coilt1.setup;

transmetteur = OxyCoilSystem(); 
transmetteur.add_coil(coilt1);
figure;
transmetteur.plot;

noyau_primaire=OxyMplate("center",[0 0],"z1",-dfer-tcoil/2,"z2",-dfer-tcoil/2-tfer ,"r",2*ro,"epaisseur",tfer,"coilsystem",transmetteur,"mur",1000);
noyau_secondaire=noyau_primaire';
noyau_secondaire.z1=tcoil/2+agap+tcoil+dfer;
noyau_secondaire.z2=tcoil/2+agap+tcoil+dfer+tfer;
noyau_primaire.setup();




noyau_primaire.plot("color","r"); hold on

noyau_secondaire.plot("color","k"); hold on

axis off;