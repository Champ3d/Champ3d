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
% validation 3D elements finis
%close all
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
open_ai = 120;
open_ao = 120;
shift_a = 120;
epsilon = 20;
%%
% --- meshsize
dnum = 30;


ri = ri - wcoil/2;
ro = ro + wcoil/2;
open_ai = open_ai + wcoil/ri*180/pi;
open_ao = open_ao + wcoil/ro*180/pi;

% --- Coil
Coil11 = SArcRectangle("id","fil_out1","center",[0 0],"ri",ri,"ro",ro,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",0,"dnum",dnum,"choosed_by","top");

Coil12 = SArcRectangle("id","fil_in1","center",[wcoil 0],"ri",ri,"ro",ro-2*wcoil,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",0,"dnum",dnum,"choosed_by","top");


Coil21 = SArcRectangle("id","fil_out2","center",[0 0],"ri",ri,"ro",ro,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",shift_a,"dnum",dnum,"choosed_by","top");

Coil22 = SArcRectangle("id","fil_in2","center",[wcoil 0],"ri",ri,"ro",ro-2*wcoil,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",shift_a,"dnum",dnum,"choosed_by","top");



Coil31 = SArcRectangle("id","fil_out3","center",[0 0],"ri",ri,"ro",ro,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",2*shift_a,"dnum",dnum,"choosed_by","top");

Coil32 = SArcRectangle("id","fil_in3","center",[wcoil 0],"ri",ri,"ro",ro-2*wcoil,"openi",open_ai-epsilon,"openo",open_ao-epsilon,...
                         "orientation",2*shift_a,"dnum",dnum,"choosed_by","top");


% --- Iron
shIron = SCircle("id","iron","center",[0 0],"r",1.5*ro,"dnum",2*dnum,"choosed_by","top");

% ---
shAirbox = SCircle("id","airbox","center",[0 0],"r",5*ro,"dnum",2*dnum,"choosed_by","top");


%% 2d mesh
m2d = TriMeshFromPDETool("shape",{Coil11,Coil12,Coil21,Coil22,Coil31,Coil32,shIron,shAirbox},"hgrad",1.9,"hmax",1);
m2d.refine([2 3 4]);
m2d.refine([2 3 4]);
m2d.refine([2 3 4]);
m2d.refine([1 5 6 7 8 ]);
%%
% figure
% m2d.plot;
% return
%%
% figure
%hold all
%m2d.dom.fil_in1.plot("face_color",f_color(1))
%m2d.dom.fil_out1.plot("face_color",f_color(2))
%return

%% mesh1d in z
m1d_z = Mesh1d();
% ---
msize1 = 4;
msize2 = 5;
msize3 = 8;
% msize1 = 2;
% msize2 = 2;
% msize3 = 4;

m1d_z.add_line1d("id","zabox_b" ,"len",2*agap,"dnum",msize3,"dtype","log-");
m1d_z.add_line1d("id","ziron_b" ,"len",tfer,"dnum",msize1,"dtype","log-");
m1d_z.add_line1d("id","zdfer_b" ,"len",dfer,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","zcoil_b" ,"len",tcoil,"dnum",msize2,"dtype","lin");
m1d_z.add_line1d("id","zagap"   ,"len",agap,"dnum",msize3,"dtype","log+-");
m1d_z.add_line1d("id","zcoil_t" ,"len",tcoil,"dnum",msize2,"dtype","lin");
m1d_z.add_line1d("id","zdfer_t" ,"len",dfer,"dnum",msize1,"dtype","lin");
m1d_z.add_line1d("id","ziron_t" ,"len",tfer,"dnum",msize1,"dtype","log+");
m1d_z.add_line1d("id","zabox_t" ,"len",2*agap,"dnum",msize3,"dtype","log+");

%% mesh3d
m3d = PrismMeshFromTriMesh("parent_mesh2d",m2d,...
                           "parent_mesh1d",m1d_z,...
                           "id_zline",{"z..."});
m3d.lock_origin("gcoordinates",[0, 0, -(agap + tfer + dfer + tcoil/2)]);


% --- dom3d-volume
m3d.add_vdom("id","iron",...
             "id_dom2d",{"iron","fil_out1","fil_out2","fil_out3","fil_in1","fil_in2","fil_in3"},...
             "id_zline",{"ziron_b","ziron_t"});
% ---transmetteur
m3d.add_vdom("id","coilt1",...
             "id_dom2d",{"fil_out1"},...
             "id_zline",{"zcoil_b"});


m3d.add_vdom("id","coilt2",...
             "id_dom2d",{"fil_out2"},...
             "id_zline",{"zcoil_b"});

m3d.add_vdom("id","coilt3",...
             "id_dom2d",{"fil_out3"},...
             "id_zline",{"zcoil_b"});

%----- recepteur


m3d.add_vdom("id","coilr1",...
             "id_dom2d",{"fil_out1"},...
             "id_zline",{"zcoil_t"});



m3d.add_vdom("id","coilr2",...
             "id_dom2d",{"fil_out2"},...
             "id_zline",{"zcoil_t"});

m3d.add_vdom("id","coilr3",...
             "id_dom2d",{"fil_out3"},...
             "id_zline",{"zcoil_t"});

% ---
% m3d.add_vdom("id","incoil1",...
%              "id_dom2d",{"ro","iron1"},...
%              "id_zline",{"zcoil_b"});
%%
% figure
% %m3d.plot("face_color","none");
% m3d.dom.coilt1.plot("face_color",f_color(1));
% m3d.dom.coilt2.plot("face_color",f_color(2));
% m3d.dom.coilt3.plot("face_color",f_color(3));
% m3d.dom.iron.plot("face_color",f_color(4));

%%
I1 = 1;
nb_turn = 1;
cs_area = wcoil * tcoil;
J1 = I1*nb_turn/cs_area;
J2 = 0;
J3 = 0;
% --- Physical model
em_t = FEM3dAphijw('parent_mesh',m3d,"frequency",0);

% --- Physical dom

em_t.add_mconductor("id","iron","id_dom3d","iron","mur",mur);
% ---
coilt1 = StrandedCloseJsCoil("parent_model",em_t,"id_dom3d","coilt1","cs_area",cs_area,...
                           "spin_vector",[0 0 1],"nb_turn",nb_turn, ...
                           "Js",J1,"coil_mode","tx");
em_t.add_coil('id','coilt1','coil_obj',coilt1);
% ---
coilt2 = StrandedCloseJsCoil("parent_model",em_t,"id_dom3d","coilt2","cs_area",cs_area,...
                           "spin_vector",[0 0 1],"nb_turn",nb_turn, ...
                           "Js",J2,"coil_mode","rx");
em_t.add_coil('id','coilt2','coil_obj',coilt2);
%-----
coilt3 = StrandedCloseJsCoil("parent_model",em_t,"id_dom3d","coilt3","cs_area",cs_area,...
                           "spin_vector",[0 0 1],"nb_turn",nb_turn, ...
                           "Js",J3,"coil_mode","rx");
em_t.add_coil('id','coilt3','coil_obj',coilt3);


% ---
em_t.solve;

L     = em_t.coil.coilt1.Flux / I1 * 1e6
Mt_12 = em_t.coil.coilt2.Flux / I1 * 1e6
Mt_13 = em_t.coil.coilt3.Flux / I1 * 1e6

%%
save valida_3pha_FEM_withCore -v7.3

return
%%
figure

em_t.coil.coilt1.plot()
em_t.coil.coilt2.plot()
em_t.coil.coilt3.plot()

%%
figure;
em_t.field{1}.A.elem.plot("id_meshdom","coilt1")
figure;
em_t.field{1}.A.elem.plot("id_meshdom","coilt2")