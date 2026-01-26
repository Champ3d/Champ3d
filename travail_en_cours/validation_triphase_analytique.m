
close all
clear all
clc

%% Geo parameters

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
%%

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

figure; clf; hold on

cmap = lines(nspire);                 
for i = 1:nspire
    spirest11(i).plot("color", cmap(i,:));
end   
view(2)



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



transmetteur = OxyCoilSystemb(); 
transmetteur.add_coil(coilarray);

transmetteur.plot;

L = 1e6*transmetteur.getL
%M=coil1.getM(coil2);

%%
figure;hold all;


turnt11.plot("color","r"); 
turnt21.plot("color","k"); 
turnt31.plot("color","m"); 
A1=turnt11.getanode("node",turnt11.dom.node,"I",1);
A2=turnt11.getanode("node",turnt21.dom.node,"I",1);
A3=turnt11.getanode("node",turnt31.dom.node,"I",1);
f_quiver(turnt11.dom.node,A1);
f_quiver(turnt21.dom.node,A2);
f_quiver(turnt31.dom.node,A3);
title("A");
view(2)


figure;hold all;


turnt11.plot("color","r"); 
turnt21.plot("color","k"); 
turnt31.plot("color","m"); 
%A1=turnt11.getanode("node",turnt11.dom.node,"I",1);
%A2=turnt11.getanode("node",turnt21.dom.node,"I",1);
%A3=turnt11.getanode("node",turnt31.dom.node,"I",1);
f_quiver(turnt11.dom.node,turnt11.dom.len);
f_quiver(turnt21.dom.node,turnt21.dom.len);
f_quiver(turnt31.dom.node,turnt31.dom.len);
title("len");
view(2)

sum( A1(1,:).*turnt11.dom.len(1,:) + A1(2,:).*turnt11.dom.len(2,:) + A1(3,:).*turnt11.dom.len(3,:) )
sum( A2(1,:).*turnt11.dom.len(1,:) + A2(2,:).*turnt11.dom.len(2,:) + A2(3,:).*turnt11.dom.len(3,:) )
sum( A3(1,:).*turnt31.dom.len(1,:) + A3(2,:).*turnt31.dom.len(2,:) + A3(3,:).*turnt31.dom.len(3,:) )