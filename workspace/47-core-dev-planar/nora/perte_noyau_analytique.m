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
agap = 100e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
alpha=1.32;
beta=2;
kappa=6.47;
fr=1000;

% ---
tfer = 200e-3;
tcoil = wcoil;
coeff=10;
Rnoyau=coeff*ro;
z1=-dfer-tcoil/2;
z2=tcoil/2+agap+tcoil+dfer;
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
dataAN.Rnoyau=Rnoyau;
dataAN.z1_plate = z1;
dataAN.mur=mur;
dataAN.alpha=alpha;
dataAN.beta=beta;
dataAN.kappa=kappa;
dataAN.fr=fr;
%%
% --- bottom coil
turn11 = OxyTurnT00b("center",[0 0],"dir",0,"ri",ri,"ro",ro,"rwire",wcoil,"z",0,"openi",180,"openo",180,"pole",+1);
turn12 = turn11'; turn12.rotate(180); turn12.pole = +1;
%%

%%
% dataAN.xline = xline;
% dataAN.node_01 = node_01;
% dataAN.node_02 = node_02;
% save dataAN dataAN;

%%
z1=-dfer-tcoil/2;
z2=tcoil/2+agap+tcoil+dfer;

%taille=z2+tfer;
taille=tfer+dfer+wcoil+agap+tcoil+dfer+tfer;

epsilon=5*max(taille,ro);

k=foundk(epsilon,z1,z2);

 coil1 = OxyCoil4("I",I1,"imagelevel",k);
 coil1.add_turn(turn11);
 coil1.add_turn(turn12);
 coil1.add_mplate("z",z1,"mur",mur);
 coil1.add_mplate("z",z2,"mur",mur);
 coil1.setup;
    % ---
 coilsystem = OxyCoilSystem(); 
 coilsystem.add_coil(coil1);


%%
noyau_primaire=OxyMplate("center",[0 0],"z1",z1,"z2",z1-tfer ,"r",Rnoyau,"epaisseur",tfer,"coilsystem",coilsystem,"mur",mur,"alpha",alpha,"beta",beta,"kappa",kappa,"fr",fr);
noyau_secondaire=noyau_primaire';
noyau_secondaire.z1=z2;
noyau_secondaire.z2=z2+tfer;
noyau_primaire.setup();


%figure;
%noyau_primaire.plot("color","r"); hold on
%noyau_secondaire.plot("color","k"); hold on
%plot3(noyau_primaire.dom.node(1,:),noyau_primaire.dom.node(2,:),noyau_primaire.dom.node(3,:),'k*');hold on

%%
N = 400;

Rline = noyau_primaire.r;
zmid=(noyau_primaire.z1+noyau_primaire.z2)/2;
x = linspace(0, Rline, N);
node_x = [x +  noyau_primaire.center(1); 0*x +  noyau_primaire.center(2); zmid*ones(1,N)];
B_xline = coil1.getbnode("node", node_x); 


Bz = B_xline(3,:);
Br = B_xline(1,:);  % car y=0, direction radiale = x
By = B_xline(2,:);
Bmag = sqrt(Br.^2 + By.^2 + Bz.^2);

figure; 
%plot(x, Br,'color','k' ,'LineWidth', 2); hold on;
%plot(x, Bz,'color','b' ,'LineWidth', 2);hold on;
plot(x,Bmag,'color','r' ,'LineWidth', 2)
grid on
xlabel('r (= x) [m]'); ylabel('B [T]');
%legend('B_r (= B_x)', 'B_z','|B|');
title('Champ dans le noyau AN: coupe radiale au milieu (z = zmid)');
return
%%
epsr = 1e-6;
zmin = min(noyau_primaire.z1, noyau_primaire.z2);
zmax = max(noyau_primaire.z1, noyau_primaire.z2);
z = linspace(zmin, zmax, N);
node_z = [epsr*ones(1,N) + noyau_primaire.center(1);0*z + noyau_primaire.center(2);z];
B_zline = coil1.getbnode("node", node_z); 

Br_z = B_zline(1,:);  % ≈ Bx car y=0
Bz_z = B_zline(3,:);
By_z= B_zline(2,:);

Bmag_z=sqrt(Br_z.^2 + By_z.^2 + Bz_z.^2);

figure;
%plot(z, Br_z, 'color','k' ,'LineWidth', 2); hold on;
%plot(z, Bz_z, 'color','b' ,'LineWidth', 2);hold on;
plot(z,Bmag_z,'color','r' ,'LineWidth', 2)
grid on
xlabel('z [m]'); ylabel('B [T]');
%legend('B_z', 'B_r (≈ B_x)','|B|');
title('Champ dans le noyau AN : coupe axiale proche de l’axe (r≈0)');

%%
dataAN.xline = x;
dataAN.zline = z;
dataAN.node_x = node_x;
dataAN.node_z = node_z;
save dataAN dataAN;

%%

perte=noyau_primaire.getperte
%%
% %%
% B=noyau_primaire.getbnode;
% temps = toc(t);
% disp(temps)
% 
% 
% 
% figure;
% f_quiver(noyau_primaire.dom.node,B);
% noyau_primaire.getperte;
