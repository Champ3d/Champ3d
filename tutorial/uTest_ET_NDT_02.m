%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

close all
clear all
clc

%% Parameters

riCoil = 2e-3;
roCoil = 4e-3;
zCoil  = 2e-3;
rPlate = 10e-3;
zPlate = 2e-3;
airgap = 1e-3;
sigPlate = 1e6;
murPlate = 1;
rBox = 2*rPlate;

%% mesh2d-FEMM
% --- Material list
mat.air      = FEMM2dMaterial();
bc.A0    = FEMM2dBCfixedA('a0',0);
% --- Draw list
draw.airbox = FEMM2dCircle('cen_x',0,'cen_y',0,'r',rBox,'max_angle_len',10);
draw.plate  = FEMM2dCircle('r',rPlate,'max_angle_len',5);
draw.roCoil = FEMM2dCircle('r',roCoil,'max_angle_len',5);
draw.riCoil = FEMM2dCircle('r',riCoil,'max_angle_len',5);

%% Build FEMM model
%  Create FEMM object
%  and add elements
% -------------------------------------------------------------------------
femmodel = FEMM2dMag('id_project','femmodel');

% --- add materials
femmodel.add_material('id_material','air','material',mat.air)

% --- add bc
femmodel.add_bc('id_bc','A0','bc',bc.A0);

% --- add draw
femmodel.add_box('id_box','airbox','draw',draw.airbox);
femmodel.add_draw('id_draw','plate','draw',draw.plate);
femmodel.add_draw('id_draw','roCoil','draw',draw.roCoil);
femmodel.add_draw('id_draw','riCoil','draw',draw.riCoil);

% --- set dom (domain = region)
% --- air
femmodel.set_dom('id_dom','airbox','id_material','air',...
                     'id_draw','airbox',...
                     'choosed_by','top');
% ---
femmodel.set_dom('id_dom','plate01','id_material','air',...
                     'id_draw','plate',...
                     'choosed_by','top',...
                     'mesh_size',rPlate/5);
femmodel.set_dom('id_dom','plate02','id_material','air',...
                     'id_draw','riCoil',...
                     'choosed_by','top',...
                     'mesh_size',riCoil/5);
femmodel.set_dom('id_dom','coil','id_material','air',...
                     'id_draw','roCoil',...
                     'choosed_by','top',...
                     'mesh_size',roCoil/5);
% --- set bound (apply boundary condition)
femmodel.set_bound('id_bound','A0','id_bc','A0','id_box','airbox');


%% take mesh2d from FEMM
femmodel.createmesh;
femmodel.getdata;
% ---
m2d_01 = femmodel.mesh;
m2d_01.dom.plate = m2d_01.dom.plate01 + m2d_01.dom.plate02 + m2d_01.dom.coil;

%% mesh1d in z
m1d_01 = Mesh1d();
% ---
msize1 = 1;
msize2 = 1;
m1d_01.add_line1d('id','zabox_b','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','zplate'  ,'len',zPlate,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zagap'  ,'len',airgap,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zcoil'  ,'len',zCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zabox_t','len',rBox,'dnum',msize2,'dtype','log+');

%% mesh3d-hex
m3d_01 = PrismMeshFromTriMesh('parent_mesh2d',m2d_01,...
                              'parent_mesh1d',m1d_01,...
                              'id_zline',{'z...'});

% --- dom3d-volume
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplate');
m3d_01.add_vdom('id','coil',...
                'id_dom2d','coil',...
                'id_zline','zcoil');
% -- dom3d-surface
m3d_01.add_sdom('id','surface_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');

%% plot mesh

% --- 2d mesh
figure
m2d_01.dom.plate.plot('face_color','c'); hold on
m2d_01.dom.coil.plot('face_color','b')
% --- 3d mesh
figure
m3d_01.dom.plate.plot('face_color','c'); hold on
m3d_01.dom.coil.plot('face_color','b')


















