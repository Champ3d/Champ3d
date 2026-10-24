
close all
clear all
clc

%% Parameters

riCoil = 2e-3;
roCoil = 4e-3;
zCoil  = 2e-3;
csCoil = (roCoil - riCoil) * zCoil;
Js = 1/csCoil;
rPlate = 20e-3;
zPlate = 2e-3;
airgap = 1e-3;
sigPlate = 1e6;
murPlate = 1;
rBox = 2*rPlate;

%% mesh2d
dnum = 20;
shape_01 = SCircle("id","ri","center",[0 0],"r",riCoil,"dnum",dnum,"choosed_by","top");
shape_02 = SCircle("id","ro","center",[0 0],"r",roCoil,"dnum",dnum,"choosed_by","top");
shape_03 = SCircle("id","rplate","center",[0 0],"r",rPlate,"dnum",dnum,"choosed_by","top");
shape_04 = SCircle("id","rair","center",[0 0],"r",rBox,"dnum",dnum,"choosed_by","top");

% ---
msh2d_01 = TriMeshFromPDETool("shape",{shape_01,shape_02,shape_03,shape_04},"hgrad",1.3,"hmax",1);
msh2d_01.add_vdom("id","coil","elem_code",[1]);
msh2d_01.add_vdom("id","plate","elem_code",[1,2,4]);

%%
figure
msh2d_01.plot; hold on
msh2d_01.dom.plate.plot("face_color",f_color(1));
msh2d_01.dom.coil.plot("face_color",f_color(2));

%% mesh1d - z
m1d_01 = Mesh1d();
% ---
msize1 = 4;
msize2 = 4;
% --- z
m1d_01.add_line1d('id','zabox01','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','zplate' ,'len',zPlate,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zagap'  ,'len',airgap,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zcoil'  ,'len',zCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zabox02','len',rBox,'dnum',msize2,'dtype','log+');

%% mesh3d - prism
m3d_01 = PrismMeshFromTriMesh("parent_mesh2d",msh2d_01,...
                              "parent_mesh1d",m1d_01,...
                              "id_zline",{"z..."});
% --- dom3d-volume
m3d_01.add_vdom("id","coil",...
                "id_dom2d",{"coil"},...
                "id_zline",{"zcoil"});
m3d_01.add_vdom("id","plate",...
                "id_dom2d",{"plate"},...
                "id_zline",{"zplate"});
m3d_01.add_sdom("id","surface_plate",...
                "defined_on","bound","id_dom3d","plate");
% ---
m3d_01.centering('plate');
m3d_01.lock_origin("gcoordinates",[0, 0, zPlate/2]);

%% plot mesh
figure
m3d_01.dom.coil.plot('face_color',f_color(1)); hold on
m3d_01.dom.plate.plot('face_color',f_color(2)); hold on

%% em model
fr = 100e3;
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
% ---
tsigma = LTensor('parent_model',em_01, ...
                 'main_dir',[1 0 0],'main_value',40e3, ...
                 'ort1_dir',[0 1 0],'ort1_value',40e3, ...
                 'ort2_dir',[0 0 1],'ort2_value',10);
em_01.add_econductor('id','plate','id_dom3d','plate','sigma',tsigma);
% ---
coil = StrandedCloseJsCoil("parent_model",em_01,'id_dom3d','coil','cs_area',csCoil,...
                           'spin_vector',[0 0 1],'nb_turn',100, ...
                           'Js',Js);
em_01.add_coil('id','mycoil','coil_obj',coil);
%% solve
em_01.solve;
%%
format long
em_01.coil.mycoil.R
em_01.coil.mycoil.L
%%
figure
coil.plot
%%
figure
em_01.field{1}.B.elem.plot('id_meshdom','whole_mesh_dom');
%%
figure
em_01.field{1}.B.elem.plot('id_meshdom','plate'); hold on
em_01.field{1}.B.elem.plot('id_meshdom','coil');
%%
figure
em_01.field{1}.J.elem.plot('id_meshdom','plate');

