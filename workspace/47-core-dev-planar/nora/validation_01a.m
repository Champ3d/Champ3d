%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

close all
clear all
clc

%% Geo parameters

I = 1;
ri =100e-3;
ro = 750e-3/2;
mu0 = 4*pi*1e-7;
wcoil = 5e-3;
agap = 200e-3;
dfer = 5e-3; % distance coil-ferrite
mur = 1000;
% ---
tfer = 10e-3;
tcoil = 5e-3;

%%
% --- meshsize
dnum = 10;

% --- Coil
shCoil01 = SArcRectangle("id","ro","center",[0 0],"ri",ri,"ro",ro,"openi",120,"openo",120,...
                         "orientation",0,"dnum",dnum,"choosed_by","top");
shCoil02 = SArcRectangle("id","iron1","center",[wcoil 0],"ri",ri,"ro",ro-2*wcoil,"openi",120,"openo",120,...
                         "orientation",0,"dnum",dnum,"choosed_by","top");

% --- Iron
shIron = SCircle("id","iron","center",[0 0],"r",1.5*ro,"dnum",2*dnum,"choosed_by","top");

% ---
shAirbox = SCircle("id","airbox","center",[0 0],"r",5*ro,"dnum",2*dnum,"choosed_by","top");


%% 2d mesh
m2d = TriMeshFromPDETool("shape",{shCoil01,shCoil02,shIron,shAirbox},"hgrad",1.3,"hmax",1);
%m2d.refine([1 2 4]);

%%
figure
m2d.plot;
% return
%% mesh1d in z
m1d_z = Mesh1d();
% ---
msize1 = 2;
msize2 = 2;
m1d_z.add_line1d("id","zabox_b" ,"len",agap,"dnum",msize2,"dtype","log-");
m1d_z.add_line1d("id","ziron_b" ,"len",tfer,"dnum",msize1,"dtype","log-");
m1d_z.add_line1d("id","zdfer_b" ,"len",dfer,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","zcoil_b" ,"len",tcoil,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","zagap"   ,"len",agap,"dnum",msize2,"dtype","log+-");
m1d_z.add_line1d("id","zcoil_t" ,"len",tcoil,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","zdfer_t" ,"len",dfer,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","ziron_t" ,"len",tfer,"dnum",msize1,"dtype","log+");
m1d_z.add_line1d("id","zabox_t" ,"len",agap,"dnum",msize2,"dtype","log+");

%% mesh3d
m3d = PrismMeshFromTriMesh("parent_mesh2d",m2d,...
                           "parent_mesh1d",m1d_z,...
                           "id_zline",{"z..."});
m3d.lock_origin("gcoordinates",[0, 0, -(agap + tfer + dfer + tcoil/2)]);
% --- dom3d-volume
m3d.add_vdom("id","iron",...
             "id_dom2d",{"iron","ro","iron1"},...
             "id_zline",{"ziron_b","ziron_t"});
% ---
m3d.add_vdom("id","coil1",...
             "id_dom2d",{"ro"},...
             "id_zline",{"zcoil_b"});
m3d.add_vdom("id","coil2",...
             "id_dom2d",{"ro"},...
             "id_zline",{"zcoil_t"});
% ---
m3d.add_vdom("id","incoil1",...
             "id_dom2d",{"ro","iron1"},...
             "id_zline",{"zcoil_b"});
%%
 figure
 m3d.plot("face_color","none");
 m3d.dom.coil1.plot("face_color",f_color(1));
m3d.dom.coil2.plot("face_color",f_color(2));
 m3d.dom.iron.plot("face_color",f_color(3));

%% Case

I1 = 1;
nb_turn = 1;
cs_area = wcoil * tcoil;
J1 = I1*nb_turn/cs_area;
J2 = 0;

% --- Physical model
em_01 = FEM3dAphijw('parent_mesh',m3d,"frequency",0);

% --- Physical dom
em_01.add_mconductor("id","iron","id_dom3d","iron","mur",mur);
% ---
coil1 = StrandedCloseJsCoil("parent_model",em_01,"id_dom3d","coil1","cs_area",cs_area,...
                           "spin_vector",[0 0 1],"nb_turn",nb_turn, ...
                           "Js",J1);
em_01.add_coil('id','coil1','coil_obj',coil1);
% ---
coil2 = StrandedCloseJsCoil("parent_model",em_01,"id_dom3d","coil2","cs_area",cs_area,...
                           "spin_vector",[0 0 1],"nb_turn",nb_turn, ...
                           "Js",J2);
 %em_01.add_coil('id','coil2','coil_obj',coil2);
% ---
em_01.solve;

%%
L  = em_01.coil.coil1.Flux / I1 * 1e6
return;
%%
vline3d = VisualLine3d("parent_model",em_01,"p0",[0 0 0],"p1",[1.5*ro 0 0],"dnum",1000);

%%
Bfem3d = vline3d.getfield("field_name","B");

%%
figure
f_quiver(vline3d.node,Bfem3d);

%%
xline.node = vline3d.node;
xline.Bx = Bfem3d(1,:);
xline.By = Bfem3d(2,:);
xline.Bz = Bfem3d(3,:);

figure
plot(xline.node(1,:), xline.Bx, "DisplayName", "Bx"); hold on
plot(xline.node(1,:), xline.By, "DisplayName", "By");
plot(xline.node(1,:), xline.Bz, "DisplayName", "Bz"); legend; xlabel("x (m)"); ylabel("B (T)");

%%
vline3d.p0 = [(ro+ri)/2, -ro, 0];
vline3d.p1 = [(ro+ri)/2, +ro, 0];
Bfem3d = vline3d.getfield("field_name","B");

%%
figure
f_quiver(vline3d.node,Bfem3d);

yline.node = vline3d.node;
yline.Bx = Bfem3d(1,:);
yline.By = Bfem3d(2,:);
yline.Bz = Bfem3d(3,:);

figure
plot(yline.node(2,:), yline.Bx, "DisplayName", "Bx"); hold on
plot(yline.node(2,:), yline.By, "DisplayName", "By");
plot(yline.node(2,:), yline.Bz, "DisplayName", "Bz"); legend; xlabel("x (m)"); ylabel("B (T)");

%%
% save Bfem_with_iron_ri5_ro20 xline yline L

%%
% save Bfem_no_iron_ri5_ro20 xline yline L



return
%%
figure
em_01.field{1}.B.elem.plot("id_meshdom","whole_mesh_dom");
axis off; colorbar off;

%%
figure
em_01.field{1}.B.elem.plot("id_meshdom","incoil1");
axis off; colorbar off;

%%
figure
em_01.field{1}.B.elem.plot("id_meshdom","iron");
axis off; colorbar off;
%%
format long
L  = em_01.coil.coil1.Flux / I1 * 1e6
M  = em_01.coil.coil2.Flux / I1 * 1e6
