clear
clc

%% main parameters
x_plate   = 10e-3;
y_plate   = 10e-3;
h_plate   = 10e-3;
nb_plates = 5;
agap      = 2e-3;
x_airbox  = x_plate * 2;
y_airbox  = x_plate * 2;
h_airbox  = x_airbox;

% ---
fr = 1e3;

% plates
% ---
sigma_1 = 58e6;
mur_1   = 10;
% ---
sigma_2 = [1e3  0    0; ...
           0    10   0; ...
           0    0    1e3];
mur_2   = [1e3  0    0; ...
           0    1    0; ...
           0    0    1];
% ---
sigma_3 = f_make_ltensor('type','ltensor',...
    'main_value',1e4,'ort1_value',1e4,'ort2_value',10,...
    'main_dir',[1 0 0],'ort1_dir',[0 1 0],'ort2_dir',[0 0 1]);
mur_3   = f_make_ltensor('type','ltensor',...
    'main_value',1e3,'ort1_value',1,'ort2_value',1,...
    'main_dir',[1 0 0],'ort1_dir',[0 1 0],'ort2_dir',[0 0 1]);
% ---
dir1 = f_make_coef('f',@f_dir1,'depend_on','celem');
dir2 = f_make_coef('f',@f_dir2,'depend_on','celem');
dir3 = f_make_coef('f',@f_dir3,'depend_on','celem');

sigma_4 = f_make_ltensor('type','ltensor',...
    'main_value',1e4,'ort1_value',1e4,'ort2_value',10,...
    'main_dir',dir1,'ort1_dir',dir2,'ort2_dir',dir3);
mur_4   = f_make_ltensor('type','ltensor',...
    'main_value',1e3,'ort1_value',1,'ort2_value',1,...
    'main_dir',dir3,'ort1_dir',dir2,'ort2_dir',dir1);

% ---
w = 10e-3;
x_data  = [-w +w +w -w -w +w +w -w].';
y_data  = [-w -w +w +w -w -w +w +w].';
z_data  = [-w -w -w -w +w +w +w +w].';
bx_data = [ 0  0  0  0  0  0  0  0].';
by_data = [ 0  0  0  0  0  0  0  0].';
bz_data = [-1 -1 -1 -1 +1 +1 +1 +1].';
% force outside point to 0
fbx = scatteredInterpolant(x_data, y_data, z_data, bx_data, 'linear', 'none');
fby = scatteredInterpolant(x_data, y_data, z_data, by_data, 'linear', 'none');
fbz = scatteredInterpolant(x_data, y_data, z_data, bz_data, 'linear', 'none');
% with extrapolation
% fbx = scatteredInterpolant(x_data, y_data, z_data, bx_data);
% fby = scatteredInterpolant(x_data, y_data, z_data, by_data);
% fbz = scatteredInterpolant(x_data, y_data, z_data, bz_data);
% ---

% Bs = f_make_coef('f',@f_bs);

% Bs = f_make_coef('f',@f_bs2,'depend_on','celem',...
%                  'varargin_list',...
%                  {'fbx',fbx,'fby',fby,'fbz',fbz,'move_step',[0 0 10e-3]});
             
Bs = f_make_coef('f',@f_bs3,'depend_on','celem',...
                 'varargin_list',...
                 {'fbx',fbx,'fby',fby,'fbz',fbz,'move_step',[0 0 10e-3]}, ...
                 'coef_type','array');

% ---
br_dir = f_make_coef('f',@fbr_dir,'depend_on','celem');
br_value = 1;


%% build 1D mesh
msize  = 6;
c3dobj = [];
% ---
c3dobj = f_add_x(c3dobj,'id_x','xair_l','d',x_airbox,'dnum',msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xplate','d',x_plate ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_x(c3dobj,'id_x','xair_r','d',x_airbox,'dnum',msize,'dtype','log+');
% ---
c3dobj = f_add_y(c3dobj,'id_y','yair_l','d',y_airbox,'dnum',msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','yplate','d',y_plate ,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','yair_r','d',y_airbox,'dnum',msize,'dtype','log+');
% ---
c3dobj = f_add_layer(c3dobj,'id_layer','lair_b','d',h_airbox,'dnum',msize,'dtype','log-');

id_layer{1} = 'lair_b';
k = 1;
for i = 1:nb_plates
    lnameplate = ['lplate_' num2str(i)];
    lnameagap  = ['lagap_'  num2str(i)];
    c3dobj = f_add_layer(c3dobj,'id_layer',lnameplate,'d',h_plate,'dnum',2*msize,'dtype','lin');
    c3dobj = f_add_layer(c3dobj,'id_layer',lnameagap ,'d',agap   ,'dnum',msize,'dtype','lin');
    % ---
    k = k + 1; id_layer{k} = lnameplate;
    k = k + 1; id_layer{k} = lnameagap;
end
c3dobj = f_add_layer(c3dobj,'id_layer','lair_t','d',h_airbox,'dnum',msize,'dtype','log+');
id_layer{end + 1} = 'lair_t';

%% build 2D mesh
c3dobj = f_add_mesh2d(c3dobj,'id_mesh2d','my_mesh2d',...
        'build_from','mesh1d',...
        'id_x', {'xair_l','xplate','xair_r'},...
        'id_y', {'yair_l','yplate','yair_r'},...
        'centering','on');

%% define dom2d
c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','my_mesh2d',...
        'id_dom2d','plate', ...
        'id_x', 'xplate',...
        'id_y', 'yplate');

%% View 2d mesh

% figure
% f_view_c3dobj(c3dobj,'id_mesh2d','my_mesh2d',...
%               'id_dom2d','plate','face_color',f_color(1),'alpha_value',0.5);  hold on

%% build 3d mesh
c3dobj = f_add_mesh3d(c3dobj,'id_mesh3d','my_mesh3d','mesher','c3d_hexamesh',...
                       'id_mesh2d',{'my_mesh2d'},...
                       'id_mesh1d',[],...
                       'id_layer',id_layer, ...
                       'centering',1);

%% define dom3d
for i = 1:nb_plates
    id_dom3d = ['plate_' num2str(i)];
    lnameplate = ['lplate_' num2str(i)];
    c3dobj = f_add_dom3d(c3dobj,'id_dom3d',id_dom3d, ...
                         'id_dom2d',{'plate'},'id_layer',lnameplate);
end
c3dobj = f_add_dom3d(c3dobj,'defined_on','bound_face',...
                      'of_dom3d','plate_1', ...
                      'id_dom3d','plate_1_surface');

%% View 3d mesh
figure
f_view_c3dobj(c3dobj,'id_dom3d','plate_1','face_color',f_color(1),'alpha_value',0.5);  hold on
f_view_c3dobj(c3dobj,'id_dom3d','plate_2','face_color',f_color(2),'alpha_value',0.5);  hold on
f_view_c3dobj(c3dobj,'id_dom3d','plate_3','face_color',f_color(3),'alpha_value',0.5);  hold on
f_view_c3dobj(c3dobj,'id_dom3d','plate_4','face_color',f_color(4),'alpha_value',0.5);  hold on
f_view_c3dobj(c3dobj,'face_color','none','alpha_value',0.5);

%% build emdesign3d em_multicubes
c3dobj = f_add_emdesign3d(c3dobj,'id_emdesign3d','em_multicubes',...
                                 'id_mesh3d','my_mesh3d',...
                                 'em_model','fem_aphijw',...
                                 'frequency',fr);

% ---
c3dobj = f_add_econductor(c3dobj,'id_econductor','plate_1',...
                                 'id_dom3d','plate_1',...
                                 'sigma',sigma_1);
c3dobj = f_add_econductor(c3dobj,'id_econductor','plate_2',...
                                 'id_dom3d','plate_2',...
                                 'sigma',sigma_2);
c3dobj = f_add_econductor(c3dobj,'id_econductor','plate_3',...
                                 'id_dom3d','plate_3',...
                                 'sigma',sigma_3);
c3dobj = f_add_econductor(c3dobj,'id_econductor','plate_4',...
                                 'id_dom3d','plate_4',...
                                 'sigma',sigma_4);
% ---
c3dobj = f_add_mconductor(c3dobj,'id_mconductor','plate_1', ...
                                 'id_dom3d','plate_1',...
                                 'mu_r',mur_1);
c3dobj = f_add_mconductor(c3dobj,'id_mconductor','plate_2', ...
                                 'id_dom3d','plate_2',...
                                 'mu_r',mur_2);
c3dobj = f_add_mconductor(c3dobj,'id_mconductor','plate_3', ...
                                 'id_dom3d','plate_3',...
                                 'mu_r',mur_3);
c3dobj = f_add_mconductor(c3dobj,'id_mconductor','plate_4', ...
                                 'id_dom3d','plate_4',...
                                 'mu_r',mur_4);
% ---
c3dobj = f_add_nomesh(c3dobj,'id_nomesh','nomesh','id_dom3d','plate_5');
% ---
c3dobj = f_add_bsfield(c3dobj,'id_bsfield','bsfield','bs',Bs);

% ---
c3dobj = f_add_airbox(c3dobj,'id_airbox','big_airbox','a_value',0);

%% Solve emdesign3d









