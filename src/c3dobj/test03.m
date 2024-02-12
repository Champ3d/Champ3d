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
mesh1d = Mesh1d();

% ---
mesh1d.add_line1d('id','xair_l','len',x_abox ,'dnum',2*msize,'dtype','log-');
mesh1d.add_line1d('id','xplate','len',x_plate,'dnum',msize,'dtype','log+-');
mesh1d.add_line1d('id','xair_r','len',x_abox ,'dnum',2*msize,'dtype','log+');

% ---
mesh1d.add_line1d('id','yair_b','len',x_abox ,'dnum',5*msize,'dtype','log-');
for i = 1:2
    idyl = ['yplate' num2str(i)];
    mesh1d.add_line1d('id',idyl,'len',l_plate,'dnum',5*msize,'dtype','lin');
end
% ---
mesh1d.add_line1d('id','yair_t'  ,'len',x_abox ,'dnum',5*msize,'dtype','log+');

% ---
mesh1d.add_line1d('id','lair_b'  ,'len',t_abox ,'dnum',2*msize,'dtype','log-');
mesh1d.add_line1d('id','lplate_1','len',t_plate,'dnum',msize,'dtype','log+-');
mesh1d.add_line1d('id','lagap_1' ,'len',agap   ,'dnum',msize,'dtype','lin');
mesh1d.add_line1d('id','lcoil'   ,'len',t_coil ,'dnum',msize,'dtype','log+-');
mesh1d.add_line1d('id','lagap_2' ,'len',agap   ,'dnum',msize,'dtype','lin');
mesh1d.add_line1d('id','lplate_2','len',t_plate,'dnum',msize,'dtype','log+-');
mesh1d.add_line1d('id','lair_t'  ,'len',t_abox ,'dnum',msize,'dtype','log+');
%% mesh2d-quad
mesh2d = Mesh2d();
mesh2d.build_from_mesh1d('mesh1d',mesh1d,...
                         'id_xline',{'xair_l' 'xplate' 'xair_r'},...
                         'id_yline',{'yair_b' 'yplate...' 'yair_t'});

figure
mesh2d.data.plot('edge_color','k');


%% mesh2d-tri
% mesh2d = mesh2d();
% mesh2d.build_from_femm('mesh_file','IV_MASSIVE_01.ans');
% 
% figure
% mesh2d.data.plot('edge_color','k');


%% dom2d
% plate_dom2d = chfactory.dom2d('parent_mesh',quadmesh,'xline',{xplate},'yline',yplate);
% extracted_mesh = plate_dom2d.extracted_mesh;





% hold on
% extracted_mesh.plot('face_color','r')

% %% mesh2d-tri
% trimesh = chfactory.mesh2d('mesh_type','tri_mesh_from_femm','mesh_file','IV_MASSIVE_01.ans');
% trimesh.build
% 
% figure
% trimesh.plot('edge_color','k');
% 
% %% dom2d
% plate_dom2d = chfactory.dom2d('parent_mesh',trimesh,'elem_code',1);
% extracted_mesh = plate_dom2d.extracted_mesh;
% 
% hold on
% extracted_mesh.plot('face_color','r')

%% mesh3d-hex
mesh3d = Mesh3d();
mesh3d.build_from_quad_mesh('mesh2d',mesh2d, ...
    'mesh1d',mesh1d, ...
    'id_zline',{'lair_b' 'lplate_1' 'lagap_1' 'lcoil' 'lagap_2' 'lplate_2' 'lair_t'});

mesh3d.data.plot('edge_color','k','face_color','none')

%% mesh3d-prism
mesh3d = Mesh3d();
mesh3d.build_from_tri_mesh('mesh2d',mesh2d, ...
    'mesh1d',mesh1d, ...
    'id_zline',{'lair_b' 'lplate_1' 'lagap_1' 'lcoil' 'lagap_2' 'lplate_2' 'lair_t'});

return
%% dom3d

plate_dom3d = chfactory.dom3d('parent_mesh',hexmesh,'dom2d',plate_dom2d,'zline',lplate_1);

extracted_mesh = plate_dom3d.extracted_mesh;

hold on
extracted_mesh.plot('face_color','r')






















































