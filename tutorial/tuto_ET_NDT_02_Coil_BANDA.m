% test mesh disc

clear all
close all
clc

%% Geo parameters
I = 1;
mu0 = 4*pi*1e-7;
agap = 0.5e-3;
sigma = 58e6;
mur = 1;
fr = 50e3;
% ---
ro_tx = 6e-3;
ri_tx = 0.25e-3;
% ---
rPlate = 19.7e-3;
tPlate = 14.5e-3;
tcoil = 1e-3;
% ---
rAir = 5 * rPlate;
lAir = 2 * rPlate;
% ---
cs_coil = tcoil * (ro_tx - ri_tx);
Js = I/cs_coil;
%% 
m2d = QuadMeshCircles('id_dom',{'core1','coil','core2','air'}, ...
                      'radius',[ri_tx, ro_tx, rPlate, rAir],...
                      'anum',11,...
                      'rnum',[2, 3, 5, 5],...
                      'rtype',{'lin','log+-','log+','log+'});

%%
% figure
% m2d.plot("face_color","none"); hold on;
% m2d.dom.coil.plot("face_color",f_color(1));
% m2d.dom.core1.plot("face_color",f_color(2));
% m2d.dom.core2.plot("face_color",f_color(3));
% m2d.dom.air.plot("face_color",f_color(4));

%% mesh1d in z
m1d_z = Mesh1d();
% ---
skdepth = min(0.5*tPlate, sqrt(2/(2*pi*fr*mur*mu0*sigma)));
m1d_z.add_line1d("id","zabox_1" ,"len",lAir,"dnum",6,"dtype","log-");
m1d_z.add_line1d("id","zplate_1","len",tPlate-2*skdepth,"dnum",5,"dtype","log-");
m1d_z.add_line1d("id","zplate_2","len",2*skdepth,"dnum",6,"dtype","log-");
m1d_z.add_line1d("id","zagap"   ,"len",agap,"dnum",2,"dtype","lin");
m1d_z.add_line1d("id","ztcoil1" ,"len",tcoil,"dnum",2,"dtype","lin");
m1d_z.add_line1d("id","zabox_2" ,"len",lAir,"dnum",6,"dtype","log+");

%% mesh3d
m3d = HexaMeshFromQuadMesh("parent_mesh2d",m2d,...
                              "parent_mesh1d",m1d_z,...
                              "id_zline",{'z...'});
m3d.lock_origin("gcoordinates",[0, 0, (lAir + tPlate)]);
% --- dom3d-volume
m3d.add_vdom("id","tx_coil",...
                "id_dom2d",{'coil'},...
                "id_zline",{'ztcoil1'});
m3d.add_vdom("id","plate",...
                "id_dom2d",{'coil','core1','core2'},...
                "id_zline",{'zplate_1','zplate_2'});

%% Case 1
% --- Physical model
em_02 = FEM3dAphijw("parent_mesh",m3d,"frequency",fr);

% --- Physical dom
em_02.add_econductor("id","plate","id_dom3d","plate","sigma",sigma);
%em_02.add_mconductor("id","fer_rx","id_dom3d","fer_rx","mur",mur);
% ---
coil = StrandedCloseJsCoil("parent_model",em_02,'id_dom3d','tx_coil','cs_area',cs_coil,...
                           'spin_vector',[0 0 1],'nb_turn',720, ...
                           'Js',Js);
em_02.add_coil('id','mycoil','coil_obj',coil);
% ---
tic
em_02.solve;
tcFEMJ = toc;
fprintf('time - FEM-Impo-J = %g \n', tcFEMJ);

%%
R = abs(real(coil.Z));
X = abs(imag(coil.Z));
fprintf("R = %g, deltaX = %g \n", R, X - 0.002*2*pi*fr);
fprintf("R = %g, X = %g \n", R, X);
fprintf("R = %g, L = %g \n", R, abs(coil.L));
%%
figure
m3d.dom.plate.plot("face_color",f_color(1));
m3d.dom.tx_coil.plot("face_color",f_color(3));
coil.plot;

%%
figure
em_02.field{1}.J.elem.plot('id_meshdom','plate'); hold on

%%
id_elem = em_02.parent_mesh.dom.plate.gindex;
% ---
celem   = em_02.parent_mesh.celem(:,id_elem);
vecX    = real(em_02.field{1}.B.elem.cvalue).';
vecX    = vecX(:,id_elem);

figure
f_quiver(em_02.parent_mesh.celem(:,id_elem),vecX); hold on

% ---
R_ = sqrt(celem(1,:).^2 + celem(2,:).^2);
vecXm = f_norm(vecX);
figure
plot(R_,vecXm,'ob');
