close all
clear all
clc

%% Geo parameters
r = 1;

%% Shape construction
shape_00 = BSphere('r',r,'center',[0 0 0]);
shape_01 = BBox('center',[2 0 0],'len',[1 1 2]);
shape_02 = BBox('center',[4 0 0],'len',[1 1 2],'orientation',[1 1 1]);
shape_03 = BTorus('center',[6 0 0],'rtorus',1,'rsection',0.5,'opening_angle',180,'orientation',[1 0 0]);
shape_04 = BCylinder('center',[7 0 0],'r',1,'hei',2,'opening_angle',180,'orientation',[0 1 0]);
shape_05 = BHollowCylinder('center',[9 0 0],'ri',0.5,'ro',1,'hei',1,'opening_angle',180,'orientation',[0 1 0]);
%% Physical Volume
mshsize = 0.5;
vdom_00 = PhysicalVolume('id','dom00','volume_shape',shape_00,'mesh_size',mshsize);
vdom_01 = PhysicalVolume('id','dom01','volume_shape',shape_01,'mesh_size',mshsize);
vdom_02 = PhysicalVolume('id','dom02','volume_shape',shape_02,'mesh_size',mshsize);
vdom_03 = PhysicalVolume('id','dom03','volume_shape',shape_03,'mesh_size',mshsize);
vdom_04 = PhysicalVolume('id','dom04','volume_shape',shape_04,'mesh_size',mshsize);
vdom_05 = PhysicalVolume('id','dom05','volume_shape',shape_05,'mesh_size',mshsize);
%% Mesh
m3d_01 = TetraMeshFromGMSH('id','tetramesh', ...
    'physical_volume',{vdom_00,vdom_01,vdom_02,vdom_03,vdom_04,vdom_05});
%%
figure
m3d_01.dom.dom00.plot('face_color',f_color(1)); hold on
m3d_01.dom.dom01.plot('face_color',f_color(2));
m3d_01.dom.dom02.plot('face_color',f_color(3));
m3d_01.dom.dom03.plot('face_color',f_color(4));
m3d_01.dom.dom04.plot('face_color',f_color(5));
m3d_01.dom.dom05.plot('face_color',f_color(6));


