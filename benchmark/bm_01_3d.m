clear
clc

%% main parameters
x_plate   = 100e-3;
y_plate   = 3e-3;
sig_plate = 40e3;
mur_plate = 1;
x_coil    = 10e-3;
y_coil    = 5e-3;
sig_coil  = 58e6;
agap      = 2e-3;
x_airbox  = x_plate * 2;
y_airbox  = x_plate * 2;
Imax      = 1000;
nb_turns  = 1;
fr        = 200e3;
Iphase    = 'IA'; 
Isign     = +1;
l_plate   = 100e-3; % length for 3d

tsig_coil  = f_make_gtensor('type','isotropic','value',sig_coil);
tsig_plate = f_make_gtensor('type','gtensor',...
    'main_value',sig_plate,'ort1_value',sig_plate,'ort2_value',sig_plate,...
    'main_dir',[0 0 1],'ort1_dir',[1 0 0],'ort2_dir',[0 1 0]);


%% build 1D mesh
msize  = 10;
c3dobj = [];
% ---
c3dobj = f_add_x(c3dobj,'id_x','xair_l'   ,'d',x_airbox/2 - x_plate/2,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xplate_l' ,'d',x_plate/2  - x_coil/2 ,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xcoil'    ,'d',x_coil                ,'dnum',msize,'dtype','log=');
c3dobj = f_add_x(c3dobj,'id_x','xplate_r' ,'d',x_plate/2  - x_coil/2 ,'dnum',2*msize,'dtype','log+');
c3dobj = f_add_x(c3dobj,'id_x','xair_r'   ,'d',x_airbox/2 - x_plate/2,'dnum',2*msize,'dtype','log+');
% ---
c3dobj = f_add_y(c3dobj,'id_y','yair_b'   ,'d',y_airbox,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','yplate'   ,'d',y_plate ,'dnum',2*msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','y_agap'   ,'d',agap    ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','ycoil'    ,'d',y_coil  ,'dnum',msize,'dtype','log=');
c3dobj = f_add_y(c3dobj,'id_y','yair_t'   ,'d',y_airbox,'dnum',2*msize,'dtype','log+');
% ---
c3dobj = f_add_layer(c3dobj,'id_layer','lplate' ,'d',l_plate,'dnum',4*msize,'dtype','lin');

%% build 2D mesh
c3dobj = f_add_mesh2d(c3dobj,'id_mesh2d','my_mesh2d',...
        'build_from','mesh1d',...
        'id_x', {'xair_l','xplate_l','xcoil','xplate_r','xair_r'},...
        'id_y', {'yair_b','yplate','y_agap','ycoil','yair_t'});

%% define dom2d
c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','my_mesh2d',...
        'id_dom2d','plate', ...
        'id_x', {'xplate_l','xcoil','xplate_r'},...
        'id_y', {'yplate'});


c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','my_mesh2d',...
        'id_dom2d','coil', ...
        'id_x', {'xcoil'},...
        'id_y', {'ycoil'});

%% view 2d mesh
figure
f_view_mesh2d(c3dobj,'color','w'); hold on
f_view_mesh2d(c3dobj,'id_dom2d','plate','color',f_color(1));
f_view_mesh2d(c3dobj,'id_dom2d','coil','color',f_color(2));


%% build 3d mesh
c3dobj = f_add_mesh3d(c3dobj,'id_mesh3d','my_mesh3d','mesher','c3d_hexamesh',...
                       'id_mesh2d',{'my_mesh2d'},...
                       'id_mesh1d',[],...
                       'id_layer',{'lplate'});

%% define dom3d
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','plate', ...
                      'id_dom2d',{'plate'},'id_layer',{'lplate'});
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','coil', ...
                      'id_dom2d',{'coil'},'id_layer',{'lplate'});


%% view 3d mesh
node = c3dobj.mesh3d.my_mesh3d.node;
elem = c3dobj.mesh3d.my_mesh3d.elem;

% ---
figure
IDElem = c3dobj.mesh3d.my_mesh3d.dom3d.plate.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(1)); hold on;
% --- 
IDElem = c3dobj.mesh3d.my_mesh3d.dom3d.coil.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color',f_color(2)); hold on;

%% build emdesign3d

c3dobj = f_add_emdesign3d(c3dobj,'id_emdesign3d','bm_01_3d','id_mesh3d',{'my_mesh3d','my_mesh3d'});

c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','bm_01_3d',...
                          'id_econductor','plate', ...
                          'id_dom3d','plate','sigma',tsig_plate);

c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','bm_01_3d',...
                          'id_econductor','coil', ...
                          'id_dom3d','coil','sigma',tsig_coil);

c3dobj = f_add_open_jscoil(c3dobj,'id_emdesign3d','bm_01_3d',...
                            'id_dom3d','coil',...
                            'id_coil','coil01',...
                            'coil_mode','transmitter',...
                            'petrode_equation',{['z > max(z)-1e-9']},...
                            'netrode_equation',{['z < min(z)+1e-9']},...
                            'j_coil',1e6);

node = c3dobj.mesh3d.my_mesh3d.node;
elem = c3dobj.mesh3d.my_mesh3d.elem;
geo  = c3dobj.emdesign3d.bm_01_3d.coil.coil01.petrode;

figure
IDElem = c3dobj.mesh3d.my_mesh3d.dom3d.coil.id_elem;
f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
             'elem_type','hex','color','none','edge_color','k'); hold on;

geo  = c3dobj.emdesign3d.bm_01_3d.coil.coil01.petrode;
IDElem = geo.id_elem;
f_viewthings('type','node','node',node(:,geo.id_node),'color',f_color(2)); hold on;
axis equal; axis tight; hold on

geo  = c3dobj.emdesign3d.bm_01_3d.coil.coil01.netrode;
IDElem = geo.id_elem;
f_viewthings('type','node','node',node(:,geo.id_node),'color',f_color(3)); hold on;
axis equal; axis tight; hold on



