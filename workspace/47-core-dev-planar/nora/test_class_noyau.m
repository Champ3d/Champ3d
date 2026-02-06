I = 1;
ri =100e-3;
ro = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
% ---
tfer = 100e-3;
tcoil = 5e-3;
epsilon=20;

nspire=2;
nbphase=3;

distance=wcoil+1e-8;
distance1=wcoil+1e-8;
alpha=1.32;
beta=2;
kappa=6.47;
fr=1000;
close all;


turnt11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",120-epsilon,"openo",120-epsilon,"pole",+1);
turnt21=turnt11';
turnt21.rotate(120);
turnt31=turnt11';
turnt31.rotate(240);

spirest11(1) = turnt11;         
namest11{1}  = 't11';           
%%%%%%%%%%%%%%%%%%%%%%%%%%% phase A pole 1 spire i%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2:nspire
    spirest11(i) = spirest11(i-1)'; 
    namest11{i} = sprintf('turnt1%d', i);  
    spirest11(i).scale(distance, distance1);
end

% figure; clf; hold on
% 
% cmap = lines(nspire);                 
% for i = 1:nspire
%     spirest11(i).plot("color", cmap(i,:));
% end   
% axis off
% 
% view(2)



coilt1 = OxyCoil4("I",1,"imagelevel",1);
for i=1:nspire
coilt1.add_turn(spirest11(i));

end
coilt1.add_mplate("z",-dfer-tcoil/2,"mur",mur);
coilt1.add_mplate("z",tcoil/2+agap+tcoil+dfer,"mur",mur);
coilt1.setup;




coilarray = {};
% --- transmitter
for i = 1:nbphase
    ccopy = coilt1';
    ccopy.rotate((i-1)*360/(nbphase));
    ccopy.setup;
    coil2=ccopy';
    % ---
    coilarray{end+1} = ccopy;
end



transmetteur = OxyCoilSystem(); 
transmetteur.add_coil(coilarray);

noyau_primaire=OxyMplate("center",[0 0],"z1",-dfer-tcoil/2,"z2",-dfer-tcoil/2-tfer ,"r",2*ro,"epaisseur",tfer,"coilsystem",transmetteur,"mur",1000,"alpha",alpha,"beta",beta,"kappa",kappa,"fr",fr);
noyau_secondaire=noyau_primaire';
noyau_secondaire.z1=tcoil/2+agap+tcoil+dfer;
noyau_secondaire.z2=tcoil/2+agap+tcoil+dfer+tfer;
noyau_primaire.setup();



%figure;
%noyau_primaire.plot("color","r"); hold on
%noyau_secondaire.plot("color","k"); hold on
%plot3(noyau_primaire.dom.node(1,:),noyau_primaire.dom.node(2,:),noyau_primaire.dom.node(3,:),'k*');hold on

t=tic;

B=noyau_primaire.getbnode;
temps = toc(t);
disp(temps)



figure;
f_quiver(noyau_primaire.dom.node,B);


any(isnan(B),'all')
[row, col] = find(isnan(B));

