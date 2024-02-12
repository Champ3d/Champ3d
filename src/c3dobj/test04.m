close all
clear
clc

%% main parameters
l_coil  = 20e-3;
x_coil  = 5e-3;
t_coil  = 5e-3;
l_plate = l_coil;
x_plate = 5e-3;
t_plate = 5e-3;
agap    = 2e-3;
x_abox  = 3*x_plate;
t_abox  = 3*x_plate;
cs_coil = x_coil*t_coil;
nb_turn = 1;
% ---
fr = 1e3;

%% mesh1d
msize  = 1;
m1dcoll = Mesh1dCollection();

% ---
m1dcoll.add_mesh1d('id','xair_l','len',x_abox ,'dnum',2*msize,'dtype','log-');
m1dcoll.add_mesh1d('id','xplate','len',x_plate,'dnum',msize,'dtype','log+-');
m1dcoll.add_mesh1d('id','xair_r','len',x_abox ,'dnum',2*msize,'dtype','log+');

% ---
m1dcoll.add_mesh1d('id','yair_b','len',x_abox ,'dnum',5*msize,'dtype','log-');
for i = 1:2
    idyl = ['yplate' num2str(i)];
    m1dcoll.add_mesh1d('id',idyl,'len',l_plate,'dnum',5*msize,'dtype','lin');
end
% ---
m1dcoll.add_mesh1d('id','yair_t'  ,'len',x_abox ,'dnum',5*msize,'dtype','log+');

% ---
m1dcoll.add_mesh1d('id','lair_b'  ,'len',t_abox ,'dnum',2*msize,'dtype','log-');
m1dcoll.add_mesh1d('id','lplate_1','len',t_plate,'dnum',msize,'dtype','log+-');
m1dcoll.add_mesh1d('id','lagap_1' ,'len',agap   ,'dnum',msize,'dtype','lin');
m1dcoll.add_mesh1d('id','lcoil'   ,'len',t_coil ,'dnum',msize,'dtype','log+-');
m1dcoll.add_mesh1d('id','lagap_2' ,'len',agap   ,'dnum',msize,'dtype','lin');
m1dcoll.add_mesh1d('id','lplate_2','len',t_plate,'dnum',msize,'dtype','log+-');
m1dcoll.add_mesh1d('id','lair_t'  ,'len',t_abox ,'dnum',msize,'dtype','log+');


%% mesh2d-quad
m2dcoll = Mesh2dCollection();
m2dcoll.add_from_mesh1d('id','qmesh01', ...
                       'mesh1d_collection',m1dcoll, ...
                       'id_xline',{'xair_l' 'xplate' 'xair_r'}, ...
                       'id_yline',{'yair_b' 'yplate...' 'yair_t'});

m2dcoll.add_from_femm('id','tmesh01', ...
                     'mesh_file','ET_NDT_02.ans');

% ---
% figure
% m2dcoll.data.qmesh01.plot('edge_color','k');
% ---
% figure
% m2dcoll.data.tmesh01.plot('edge_color','k','face_color','none');

% ---
m2dcoll.data.qmesh01.build_meshds;
m2dcoll.data.qmesh01.check_meshds;
m2dcoll.data.qmesh01.build_intkit;
% ---
m2dcoll.data.tmesh01.build_meshds;
m2dcoll.data.tmesh01.check_meshds;
m2dcoll.data.tmesh01.build_intkit;
%% dom2d
qdom2dcoll = Dom2dCollection('parent_mesh',m2dcoll.data.qmesh01);
qdom2dcoll.add_volume_dom2d('id','plate',...
                            'id_xline','xplate','id_yline',{'yplate...'});

figure
submesh = qdom2dcoll.data.plate.submesh;
m2dcoll.data.qmesh01.plot('edge_color','k'); hold on
submesh{1}.plot('edge_color','k','face_color','m'); hold on
submesh{1}.build_meshds;
submesh{1}.check_meshds;
submesh{1}.build_intkit;

% ---
tdom2dcoll = Dom2dCollection('parent_mesh',m2dcoll.data.tmesh01);
tdom2dcoll.add_volume_dom2d('id','d1','elem_code',1);
tdom2dcoll.add_volume_dom2d('id','d2','elem_code',2);
tdom2dcoll.add_volume_dom2d('id','d3','elem_code',3);
tdom2dcoll.add_volume_dom2d('id','d4','elem_code',4);
figure
submesh = tdom2dcoll.data.d1.submesh;
m2dcoll.data.tmesh01.plot('edge_color','k'); hold on
tdom2dcoll.data.d1.submesh{1}.plot('edge_color','k','face_color',f_color(2)); hold on
tdom2dcoll.data.d2.submesh{1}.plot('edge_color','k','face_color',f_color(3)); hold on
tdom2dcoll.data.d3.submesh{1}.plot('edge_color','k','face_color',f_color(4)); hold on
tdom2dcoll.data.d4.submesh{1}.plot('edge_color','k','face_color',f_color(5)); hold on

submesh{1}.build_meshds;
submesh{1}.check_meshds;
submesh{1}.build_intkit;


%% mesh3d-hex

m3dcoll = Mesh3dCollection();

m3dcoll.add_from_mesh2d('id','hexamesh01', ...
                'mesh1d_collection',m1dcoll, ...
                'mesh2d_collection',m2dcoll, ...
                'id_mesh2d','qmesh01', ...
                'id_zline',{'l...'});

m3dcoll.add_from_mesh2d('id','prismmesh01', ...
                'mesh1d_collection',m1dcoll, ...
                'mesh2d_collection',m2dcoll, ...
                'id_mesh2d','tmesh01', ...
                'id_zline',{'l...'});
% ---
figure
m3dcoll.data.hexamesh01.build_meshds;
m3dcoll.data.hexamesh01.check_meshds;
m3dcoll.data.hexamesh01.build_intkit;
m3dcoll.data.hexamesh01.plot('edge_color','k','face_color','none');

% ---
figure
m3dcoll.data.prismmesh01.build_meshds;
m3dcoll.data.prismmesh01.check_meshds;
m3dcoll.data.prismmesh01.build_intkit;
m3dcoll.data.prismmesh01.plot('edge_color','k','face_color','none');



%% dom3d
hdom3dcoll = Dom3dCollection('parent_mesh',m3dcoll.data.hexamesh01);
hdom3dcoll.add_volume_dom3d('id','plate',...
                            'dom2d_collection',qdom2dcoll, ...
                            'id_dom2d','plate','id_zline','lplate...');

figure
submesh = hdom3dcoll.data.plate.submesh{1};
submesh.build_meshds;
submesh.check_meshds;
submesh.build_intkit;
submesh.plot('edge_color','r','face_color','r'); hold on
m3dcoll.data.hexamesh01.plot('edge_color','k','face_color','none');

















































