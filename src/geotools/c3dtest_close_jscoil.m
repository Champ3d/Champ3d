%--------------------------------------------------------------------------
% Test close jscoil
% 22/05/2023
% HK.B
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

clear
close all
clc

%% main geo parameters
x_plate   = 100e-3;
y_plate   = 100e-3;
h_plate_b = 1e-3;
h_plate_t = 1e-3;
ag_plate  = 1e-3;
t_coil    = 10e-3;
x_coil    = 50e-3;
y_coil    = 50e-3;
ag_coil   = 2e-3;
h_coil    = 100e-3;
agap     = 2e-3;
x_airbox  = 2 * x_plate;
y_airbox  = 2 * y_plate;
h_airbox  = 20e-3;

%% main em parameters
% ---
sig_plate_b = 58e6;
mur_plate_b = 1;
% ---
sig_plate_t_main = 40e3;
sig_plate_t_orth = 40e3;
sig_plate_t_n    = 40e3;
main_dir = [1 0 0]; % defined for assigned 0
ort1_dir = [0 1 0]; % defined for assigned 0
ort2_dir = [0 0 1]; % defined for assigned 0
uaxis    = [0 0 1]; % rotate around Oz;
rot_ang  = 0;
mur_plate_t = 1;
sig_coil    = 58e6;
% ---
fr = 20e3;
imax = 100;
% ---
tsig_coil    = f_make_gtensor('type','isotropic','value',sig_coil);
tsig_plate_b = f_make_gtensor('type','isotropic','value',sig_plate_b);
tsig_plate_t = f_make_gtensor('type','gtensor',...
              'main_value',sig_plate_t_main,'ort1_value',sig_plate_t_orth,'ort2_value',sig_plate_t_n,...
              'main_dir',main_dir,'ort1_dir',ort1_dir,'ort2_dir',ort2_dir,...
              'rot_axis',uaxis,'angle',rot_ang);

%% build 1D mesh
msize  = 2;
c3dobj = [];
% ---
c3dobj = f_add_x(c3dobj,'id_x','xair_l'   ,'d',x_airbox/2 - x_plate/2,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xplate_l' ,'d',x_plate/2  - x_coil/2 ,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','x_tcoil_l','d',t_coil                ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_x(c3dobj,'id_x','xcoil_c'  ,'d',x_coil - 2*t_coil     ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_x(c3dobj,'id_x','x_tcoil_r','d',t_coil                ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_x(c3dobj,'id_x','xplate_r' ,'d',x_plate/2  - x_coil/2 ,'dnum',2*msize,'dtype','log+');
c3dobj = f_add_x(c3dobj,'id_x','xair_r'   ,'d',x_airbox/2 - x_plate/2,'dnum',2*msize,'dtype','log+');
% ---
c3dobj = f_add_y(c3dobj,'id_y','yair_b'   ,'d',y_airbox/2 - y_plate/2,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','yplate_b' ,'d',y_plate/2  - y_coil/2 ,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','y_tcoil_b','d',t_coil                ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','ycoil_b'  ,'d',y_coil/2 - t_coil/2 - t_coil,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','ycoil_c'  ,'d',t_coil                ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','ycoil_t'  ,'d',y_coil/2 - t_coil/2 - t_coil,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','y_tcoil_t','d',t_coil                ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','yplate_t' ,'d',y_plate/2  - y_coil/2 ,'dnum',2*msize,'dtype','log+');
c3dobj = f_add_y(c3dobj,'id_y','yair_t'   ,'d',y_airbox/2 - y_plate/2,'dnum',2*msize,'dtype','log+');
% ---
c3dobj = f_add_layer(c3dobj,'id_layer','air_b'    ,'d',h_airbox   ,'dnum',msize,'dtype','log-');
c3dobj = f_add_layer(c3dobj,'id_layer','hplate_b' ,'d',h_plate_b  ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','agplate'  ,'d',ag_plate   ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','hplate_t1','d',h_plate_t/2,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','hplate_t2','d',h_plate_t/2,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','agap'     ,'d',agap       ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','tcoil_b'  ,'d',t_coil     ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','ag_coil'  ,'d',ag_coil    ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','tcoil_t'  ,'d',t_coil     ,'dnum',msize,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','hcoil'    ,'d',h_coil     ,'dnum',2*msize,'dtype','log+-');

%% build 2D mesh
c3dobj = f_add_mesh2d(c3dobj,'id_mesh2d','mesh2d_coil_test','build_from','mesh1d',...
        'id_x', {'xair_l','xplate_l','x_tcoil_l','xcoil_c','x_tcoil_r','xplate_r','xair_r'},...
        'id_y', {'yair_b','yplate_b','y_tcoil_b','ycoil_b','ycoil_c','ycoil_t','y_tcoil_t','yplate_t','yair_t'});

%% define dom2d
c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_coil_test',...
        'id_dom2d','plate', ...
        'id_x', {'xplate_l','x_tcoil_l','xcoil_c','x_tcoil_r','xplate_r'},...
        'id_y', {'yplate_b','y_tcoil_b','ycoil_b','ycoil_c','ycoil_t','y_tcoil_t','yplate_t'});

c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_coil_test',...
        'id_dom2d','petrode', ...
        'id_x', {'x_tcoil_l'},...
        'id_y', {'ycoil_c'});

c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_coil_test',...
        'id_dom2d','netrode', ...
        'id_x', {'x_tcoil_r'},...
        'id_y', {'ycoil_c'});

c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_coil_test',...
        'id_dom2d','coilshape', ...
        'id_x', {{'x_tcoil_l'}, {'xcoil_c'}, {'x_tcoil_r'}},...
        'id_y', {{'y_tcoil_b','ycoil_b','ycoil_c','ycoil_t','y_tcoil_t'}, ...
                 {'y_tcoil_b','y_tcoil_t'}, ...
                 {'y_tcoil_b','ycoil_b','ycoil_c','ycoil_t','y_tcoil_t'}});

%% view 2d mesh
figure
f_view_mesh2d(c3dobj,'color','w'); hold on
f_view_mesh2d(c3dobj,'id_dom2d','plate','color',f_color(1));
f_view_mesh2d(c3dobj,'id_dom2d','petrode','color',f_color(2));
f_view_mesh2d(c3dobj,'id_dom2d','netrode','color',f_color(3));
f_view_mesh2d(c3dobj,'id_dom2d','coilshape','color',f_color(4));


%% build 3d mesh
c3dobj = f_add_mesh3d(c3dobj,'id_mesh3d','mesh3d_coil_test','mesher','c3d_hexamesh',...
                       'id_mesh2d',{'mesh2d_coil_test'},...
                       'id_mesh1d',[],...
                       'id_layer',{'air_b','hplate_b','agplate','hplate_t1','hplate_t2','agap','tcoil_b','ag_coil','tcoil_t','hcoil'});

%% define dom3d
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','plate_b', ...
                      'id_dom2d',{'plate'},'id_layer',{'hplate_b'});
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','plate_t', ...
                      'id_dom2d',{'plate'},'id_layer',{'hplate_t...'});
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','coil_1', ...
                      'id_dom2d',{{'coilshape'},{'petrode','netrode'},{'coilshape'},{'petrode','netrode'}},...
                      'id_layer',{{'tcoil_b'}  ,{'ag_coil'}          ,{'tcoil_t'}  ,{'hcoil'}});
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','coil_2', ...
                      'id_dom2d',{'coilshape'},...
                      'id_layer',{'tcoil_b'  });
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','coil_3', ...
                      'id_dom2d',{'coilshape'},...
                      'id_layer',{'tcoil_t'  });
%% view 3d mesh
node = c3dobj.mesh3d.mesh3d_coil_test.node;
elem = c3dobj.mesh3d.mesh3d_coil_test.elem;

% ---
figure
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.plate_b.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(2)); hold on;
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.plate_t.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(3),'edge_color','k'); hold on;
% --- 
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.coil_1.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(1)); hold on;
% --- 
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.coil_2.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(4)); hold on;
% --- 
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.coil_3.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(5)); hold on;
%% build emdesign3d

c3dobj = f_add_emdesign3d(c3dobj,'id_emdesign3d','test_close_jscoil','id_mesh3d','mesh3d_coil_test');

c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','test_close_jscoil',...
                          'id_econductor','plate_b', ...
                          'id_dom3d','plate','sigma',tsig_plate_b);
                      
c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','test_close_jscoil',...
                          'id_econductor','plate_t', ...
                          'id_dom3d','plate','sigma',tsig_plate_t);
                      
c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','test_close_jscoil',...
                          'id_econductor','coil_1', ...
                          'id_dom3d','coil','sigma',tsig_coil);
                      
c3dobj = f_add_open_jscoil(c3dobj,'id_emdesign3d','test_close_jscoil',...
                            'id_dom3d','coil_1',...
                            'id_coil','js_coil',...
                            'coil_mode','transmitter',...
                            'petrode_equation',{['z > max(z)-1e-9']},...
                            'netrode_equation',{['z < min(z)+1e-9']},...
                            'j_coil',1e6);

node = c3dobj.mesh3d.mesh3d_coil_test.node;
elem = c3dobj.mesh3d.mesh3d_coil_test.elem;
geo = c3dobj.emdesign3d.test_close_jscoil.coil.js_coil.petrode;

figure
IDElem = c3dobj.mesh3d.mesh3d_coil_test.dom3d.coil_1.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color','none','edge_color','k'); hold on;
IDElem = geo.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(1)); hold on;
f_viewthings('type','node','node',node(:,geo.id_node),'color',f_color(2)); hold on;
axis equal; axis tight; hold on

f_viewthings('type','edge','node',node,'elem',edge(:,:),...
             'elem_type','hex','color',f_color(1)); hold on;

