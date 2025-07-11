close all
clear all
clc

%% Geo parameters
wplat = 10e-3;
wagap = 1e-3;
wcoil = 5e-3;
wabox = 50e-3;
zplat = 5e-3;
zcoil = 5e-3;
zabox = 50e-3;
cs_area = wcoil * zcoil;
% ---
msize1 = 3;
msize2 = 4;
%% mesh1d

m1d_01 = Mesh1d();

% --- x
m1d_01.add_line1d('id','xabox_l','len',wabox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','xplat_l','len',wplat,'dnum',2*msize1,'dtype','log+');
m1d_01.add_line1d('id','xcoil_i','len',wcoil,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','xplat_r','len',wplat,'dnum',2*msize1,'dtype','log-');
m1d_01.add_line1d('id','xcoil_o','len',wabox,'dnum',msize1,'dtype','log+');
m1d_01.add_line1d('id','xcoil_c','len',wcoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xabox_r','len',wabox,'dnum',msize2,'dtype','log+');
% --- y
m1d_01.add_line1d('id','yabox_b','len',wabox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','yplat_b','len',wplat,'dnum',2*msize1,'dtype','log+');
m1d_01.add_line1d('id','ycoil_b','len',wcoil,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','ycoil_c','len',wcoil,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','ycoil_t','len',wcoil,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','yplat_t','len',wplat,'dnum',2*msize1,'dtype','log-');
m1d_01.add_line1d('id','yabox_t','len',wabox,'dnum',msize2,'dtype','log+');
% --- z
m1d_01.add_line1d('id','zabox_b','len',zabox,'dnum',3*msize1,'dtype','log-');
m1d_01.add_line1d('id','zplat'  ,'len',zplat,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','zagap'  ,'len',wagap,'dnum',  msize1,'dtype','lin');
m1d_01.add_line1d('id','zcoil'  ,'len',zcoil,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','zagap2' ,'len',wagap,'dnum',  msize1,'dtype','lin');
m1d_01.add_line1d('id','zplat2' ,'len',zplat,'dnum',2*msize1,'dtype','lin');
m1d_01.add_line1d('id','zabox_t','len',zabox,'dnum',msize2,'dtype','log+');

%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline',{'xabox_l','xplat_l','xcoil_i','xplat_r','xcoil_o'},...
           'id_yline','y...');
% --- dom2d
m2d_01.add_vdom('id','plate',...
    'id_xline',{'xplat_l','xcoil_i','xplat_r'},...
    'id_yline',{'yplat_b','ycoil_b','ycoil_c','ycoil_t','yplat_t'});
m2d_01.add_vdom('id','coil',...
    'id_xline',{ 'xcoil_i',                     {'xplat_r','xcoil_o'}},...
    'id_yline',{{'ycoil_b','ycoil_c','ycoil_t'},{'ycoil_b','ycoil_t'}});

%% mesh2d-quad
m2d_02 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline',{'xabox_l','xplat_l','xcoil_i','xplat_r','xcoil_o','xcoil_c','xabox_r'},...
           'id_yline','y...');
% --- dom2d
m2d_02.add_vdom('id','plate',...
    'id_xline',{'xplat_l','xcoil_i','xplat_r'},...
    'id_yline',{'yplat_b','ycoil_b','ycoil_c','ycoil_t','yplat_t'});
m2d_02.add_vdom('id','coil',...
    'id_xline',{{'xcoil_i','xcoil_c'},          {'xplat_r','xcoil_o'}},...
    'id_yline',{{'ycoil_b','ycoil_c','ycoil_t'},{'ycoil_b','ycoil_t'}});

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
m3d_01.lock_origin('gcoordinates',[0 wabox + wplat + wcoil + wcoil/2 0]);
% --- dom3d-volume
m3d_01.add_vdom('id','coil',...
                'id_dom2d','coil',...
                'id_zline','zcoil');
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplat');
m3d_01.add_vdom('id','plate2',...
                'id_dom2d','plate',...
                'id_zline','zplat2');
% -- dom3d-surface
m3d_01.add_sdom('id','surface_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
m3d_01.add_sdom('id','surface_coil',...
                'defined_on','bound_face',...
                'id_dom3d','coil');
m3d_01.add_sdom('id','surface_plate2',...
                'defined_on','bound_face',...
                'id_dom3d','plate2');

% ---
m3d_01.centering('coil');


%% mesh3d-hex
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_02,...
                              'id_zline',{'z...'});
% --- dom3d-volume
m3d_02.add_vdom('id','coil',...
                'id_dom2d','coil',...
                'id_zline','zcoil');
m3d_02.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplat');
m3d_02.add_vdom('id','plate2',...
                'id_dom2d','plate',...
                'id_zline','zplat2');
% -- dom3d-surface
m3d_02.add_sdom('id','surface_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
m3d_02.add_sdom('id','surface_coil',...
                'defined_on','bound_face',...
                'id_dom3d','coil');
m3d_02.add_sdom('id','surface_plate2',...
                'defined_on','bound_face',...
                'id_dom3d','plate2');

%% Physical Parameters
sigma_plate = 1e7;
sigma_coil  = 1e7;
fr    = 1e2;
Js    = 1e6;
mur   = 1;
mu0   = 4*pi*1e-7;
% ---
skindepth_plate = sqrt(2/(2*pi*fr*sigma_plate*mu0*mur));
ratioskdz_plate = skindepth_plate/zplat;
skindepth_coil  = sqrt(2/(2*pi*fr*sigma_coil*mu0*mur));
ratioskdz_coil  = skindepth_coil/zcoil;
fprintf('Skin depth plate : %.0f μm \n', 1e6*skindepth_plate);
fprintf('sd/z plate : %f \n', ratioskdz_plate);
fprintf('Skin depth coil : %.0f μm \n', 1e6*skindepth_coil);
fprintf('sd/z coil : %f \n', ratioskdz_coil);



return


%% Case 1 - 
% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% --- Physical dom
em_01.add_econductor('id','plate','id_dom3d','plate','sigma',sigma_plate);
em_01.add_mconductor('id','plate','id_dom3d','plate','mur',mur);
% ---
coil_01b = StrandedOpenJsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Js',Js);
em_01.coil.mycoil = coil_01b;

% ---
figure
coil_01b.plot;

% ---
em_01.solve;

% ---
figure
em_01.field{1}.J.elem.plot('id_meshdom','plate');

%% Case 2 - 
% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% --- Physical dom
em_01.add_econductor('id','plate','id_dom3d','plate','sigma',sigma_plate);
em_01.add_econductor('id','coil','id_dom3d','coil','sigma',sigma_coil);
% ---
coil_01b = SolidOpenIsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Is',Js * cs_area);
em_01.coil.mycoil = coil_01b;

% ---
figure
coil_01b.plot;

% ---
em_01.solve;

% ---
figure
em_01.field{1}.J.elem.plot('id_meshdom','plate'); hold on;
em_01.field{1}.J.elem.plot('id_meshdom','coil'); hold on;
%% Case 3 - 
% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% --- Physical dom
em_01.add_econductor('id','plate','id_dom3d','plate','sigma',sigma_plate);
em_01.add_econductor('id','coil','id_dom3d','coil','sigma',sigma_coil);
% ---
coil_01b = SolidOpenVsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Vs',0.01);
em_01.coil.mycoil = coil_01b;
% ---
figure
coil_01b.plot;

% ---
em_01.solve;

% ---
figure
em_01.field{1}.J.elem.plot('id_meshdom','plate'); hold on;
em_01.field{1}.J.elem.plot('id_meshdom','coil'); hold on;

%% Case 3 - 
% --- Physical model
em_02 = FEM3dAphijw('parent_mesh',m3d_02,'frequency',fr);
% --- Physical dom
em_02.add_econductor('id','plate','id_dom3d','plate','sigma',sigma_plate);
% ---
coil_02c = StrandedCloseJsCoil('parent_model',em_02,...
                  'id_dom3d','coil',...
                  'spin_vector',[0 0 1],...
                  'Js',Js);
em_02.coil.mycoil = coil_02c;
% ---
figure
coil_02c.plot;

% ---
em_02.solve;

% ---
figure
em_02.field{1}.J.elem.plot('id_meshdom','plate'); hold on;

%% Case 4 - /!\ take time --> XTODO : why ?
% --- Physical model
em_02 = FEM3dAphijw('parent_mesh',m3d_02,'frequency',fr);
% --- Physical dom
em_02.add_sibc('id','plate','id_dom3d','surface_plate','sigma',sigma_plate);
em_02.add_nomesh('id','nomesh','id_dom3d','plate');
% ---
coil_02c = StrandedCloseJsCoil('parent_model',em_02,...
                  'id_dom3d','coil',...
                  'spin_vector',[0 0 1],...
                  'Js',Js);
em_02.coil.mycoil = coil_02c;
% ---
figure
coil_02c.plot;

% ---
em_02.solve;

% ---
figure
em_02.field{1}.J.face.plot('id_meshdom','surface_plate'); hold on;

%% Case 5 - 
% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% --- Physical dom
em_01.add_sibc('id','plate','id_dom3d','surface_plate','sigma',sigma_plate);
em_01.add_nomesh('id','nomesh','id_dom3d','plate');
em_01.add_sibc('id','coil','id_dom3d','surface_coil','sigma',sigma_coil);
em_01.add_nomesh('id','nomesh','id_dom3d','coil');
% ---
coil_01b = SolidOpenIsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Is',Js * cs_area);
em_01.coil.mycoil = coil_01b;

% ---
figure
coil_01b.plot

% ---
em_01.solve;

% ---
figure
em_01.field{1}.J.face.plot('id_meshdom','surface_plate'); hold on;
em_01.field{1}.J.face.plot('id_meshdom','surface_coil');
%% Case 6 - 
% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% --- Physical dom
em_01.add_sibc('id','plate','id_dom3d','surface_plate','sigma',sigma_plate);
em_01.add_nomesh('id','nomesh','id_dom3d','plate');
% ---
coil_01b = StrandedOpenJsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Js',Js);
em_01.coil.mycoil = coil_01b;
% ---
figure
coil_01b.plot

% ---
em_01.solve;

% ---
figure
em_01.field{1}.J.face.plot('id_meshdom','surface_plate'); hold on;

%% Case 7 -
% --- Physical model
em_01 = FEM3dAphits('parent_mesh',m3d_01);

ltime = LTime('t0',0,'t_end',1/fr/4,'dnum',10);
em_01.add_ltime(ltime);
% --- Physical dom
em_01.add_econductor('id','plate','id_dom3d','plate','sigma',sigma_plate);
em_01.add_mconductor('id','plate','id_dom3d','plate','mur',mur);
% ---
Jst = ScalarParameter('parent_model',em_01,'f',@(t)(Js*cos(2*pi*fr*t)),'depend_on','ltime','from',em_01);
coil_01b = StrandedOpenJsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & x = max(x)','y < 0 & x = max(x)'},...
                  'Js',Jst);
em_01.coil.mycoil = coil_01b;

% ---
figure
coil_01b.plot;

% ---
em_01.solve;

% ---
for it = 2:ltime.it_max
    figure
    em_01.field{it}.J.elem.plot('id_meshdom','plate');
end



