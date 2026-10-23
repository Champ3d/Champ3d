
close all
clear all
clc

%% Parameters

riCoil = 2e-3;
roCoil = 4e-3;
zCoil  = 2e-3;
csCoil = (roCoil - riCoil) * zCoil;
Js = 1/csCoil;
rPlate = 50e-3;
zPlate = 2e-3;
airgap = 1e-3;
sigPlate = 1e6;
murPlate = 1;
rBox = 2*rPlate;

%% mesh3d - coil
% --- shape
shape_01 = BHollowCylinder('center',[0 0 0],'ri',riCoil,'ro',roCoil,'hei',zCoil,'opening_angle',360,'orientation',[0 0 1]);
shape_02 = BSphere('r',10*roCoil,'center',[0 0 0]);
shape_03 = shape_02 - shape_01;
% --- Physical Volume
msize1 = riCoil/5;
vdom_01 = PhysicalVolume('id','coil','volume_shape',shape_01,'mesh_size',msize1);
vdom_02 = PhysicalVolume('id','air','volume_shape',shape_03);
% --- Mesh
m3d_01 = TetraMeshFromGMSH('id','coilmesh','physical_volume',{vdom_01,vdom_02});
m3d_01.centering("coil");
m3d_01.lock_origin("gcoordinates",[0, 0, -(zCoil/2 + airgap)]);
%% --- figure
m3d_01.dom.coil.plot('face_color',f_color(1)); hold on
m3d_01.dom.air.plot('face_color','none');

%% mesh3d - plate
m1d_01 = Mesh1d();
% ---
msize1 = 4;
msize2 = 4;
% --- x
m1d_01.add_line1d('id','xabox01','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','xplate','len',rPlate,'dnum',msize1,'dtype','log-+');
m1d_01.add_line1d('id','xabox02','len',rBox,'dnum',msize2,'dtype','log+');
% --- y
m1d_01.add_line1d('id','yabox01','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','yplate','len',rPlate,'dnum',msize1,'dtype','log-+');
m1d_01.add_line1d('id','yabox02','len',rBox,'dnum',msize2,'dtype','log+');
% --- z
m1d_01.add_line1d('id','zabox01','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','zplate' ,'len',zPlate,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zagap'  ,'len',airgap,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zabox02','len',rBox,'dnum',msize2,'dtype','log+');

% --- mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% --- dom2d
m2d_01.add_vdom('id','plate',...
    'id_xline',{'xplate'},...
    'id_yline',{'yplate'});

% --- mesh3d-hex
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});

% --- dom3d-volume
m3d_02.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplate');
% -- dom3d-surface
m3d_02.add_sdom('id','surface_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
% ---
m3d_02.centering('plate');
m3d_02.lock_origin("gcoordinates",[0, 0, zPlate/2]);

%% plot mesh
figure
m3d_01.dom.coil.plot('face_color',f_color(1)); hold on
m3d_02.dom.plate.plot('face_color',f_color(2)); hold on








