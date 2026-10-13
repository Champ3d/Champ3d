
close all
clear all
fclose("all");
clc

%% Geo parameters
lairbox  = 10e-3;
xplate = 20e-3;
yplate = 100e-3;
zplate = 150e-6;
nplate = 2;
% ---
wcoil  = 10e-3;
tcoil  = 5e-3;
acoil  = 2e-3;
xcoil  = 30e-3;
ycoil  = 2*wcoil+2*acoil;
zcoil  = 100e-3;
% ---
xfer = 10e-3;
yfer = 6*wcoil;
zfer = wcoil;
% ---
agap = 2e-3;
% --- mesh-size
msize1 = 2;
msize2 = 2;

%%
sh3d_01 = BBox('center',[0 0 0],'len',[xfer yfer zfer],'orientation',[0 0 1]);
sh3d_01.translate('distance',[0 0 3*zfer/2]);
sh3d_02 = BBox('center',[0 -(yfer-zfer)/2 0],'len',[xfer zfer zfer],'orientation',[0 0 1]);
sh3d_02.translate('distance',[0 0 zfer/2]);
sh3d_02.translate('distance',[0 (yfer-zfer)/2 0],'nb_copy',3);

fer_shape = sh3d_01 + sh3d_02;

%%
cur1d = BCurve('start_node',[0 0 0],'type','open','rmin',2.5e-3);
cur1d.zgo('len',-zcoil);
cur1d.xgo('len',-xcoil);
cur1d.ago_xy('center',[-xcoil ycoil/2 -zcoil],'angle',180,'dnum',10,'dir','clock','id','pin');
cur1d.xgo('len',+xcoil);
cur1d.zgo('len',+zcoil);
cur1d.flagfit('id_flag','pin','destination',[-xfer/2 0 zfer/2],'orientation',[0 0 1],'rotation',0);

sh2d_01 = BRectangle('len',[tcoil wcoil],'r_corner',1e-3);
sh2d_02 = BRectangle('len',[tcoil/2 wcoil/2],'r_corner',0.5e-3);

sh2d = sh2d_01 - sh2d_02;

coil_shape = BCoilShape('curve_shape',cur1d,'cross_section',sh2d,'rotation',0);

%%
airbox_shape = BBox('center',[0 0 0],'len',[120e-3 120e-3 120e-3]);

%%
vdom_01 = PhysicalVolume('id','fer','volume_shape',fer_shape,'mesh_size',0.002);
vdom_02 = PhysicalVolume('id','coil','volume_shape',coil_shape,'mesh_size',0.001);
vdom_03 = AirboxVolume('id','air','volume_shape',airbox_shape,'mesh_size',0.005);

%%
m3d_01 = TetraMeshFromGMSH('id','tuto_IH_02','physical_volume',{vdom_01,vdom_02},...
                           'airbox_volume',vdom_03);
%m3d_01.lock_origin('gcoordinates',[0 0 agap]);

%%

m3d_01.add_sdom('id','scoil','defined_on','bound','id_dom3d','coil');
m3d_01.add_sdom('id','netrode','defined_on','bound','id_dom3d','coil','condition','z = max(z) && y > 0');
m3d_01.add_sdom('id','petrode','defined_on','bound','id_dom3d','coil','condition','z = max(z) && y < 0');


%%
figure
m3d_01.dom.fer.plot('face_color',f_color(1)); hold on
m3d_01.dom.coil.plot('face_color','none'); hold on

figure
m3d_01.dom.scoil.plot('face_color','none');
m3d_01.dom.netrode.plot('face_color','k');
m3d_01.dom.petrode.plot('face_color','r');

%%

fr = 1e5;
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);

%em_01.add_econductor('id','coil','id_dom3d','coil','sigma',1e7);
em_01.add_sibc('id','coil','id_dom3d','scoil','sigma',1e7);
em_01.add_nomesh('id','coil','id_dom3d','coil');
em_01.add_mconductor('id','fer','id_dom3d','fer','mur',2000);

coil_01 = SolidOpenIsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & z = max(z)','y < 0 & z = max(z)'},...
                  'Is',250);
em_01.add_coil('id','mycoil','coil_obj',coil_01);

em_01.solve;

%%
figure
em_01.field{1}.E.face.plot('id_meshdom','scoil'); hold on

%%
figure
em_01.field{1}.J.face.plot('id_meshdom','scoil'); hold on

%%
figure
em_01.field{1}.B.elem.plot('id_meshdom','fer'); hold on

%%

idelem = m3d_01.dom.fer.gindex;
cpoint = m3d_01.celem(:,idelem);
cvec   = em_01.field{1}.B.elem.cvalue(idelem);
figure
f_quiver(cpoint,imag(cvec));

%%
figure
em_01.field{1}.Phi.node.plot('id_meshdom','coil'); hold on












