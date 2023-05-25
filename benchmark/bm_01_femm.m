%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


% ---
close all
clear
clc
% --- add femm path
addpath(genpath('C:\femm42'));


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

%% FEMM preparation
closefemm
openfemm
newdocument(0) 
%main_maximize;
file2save = 'Inf_line_current_over_plate';
femfile   = [file2save '.fem'];
meshfile  = [file2save '.ans'];
mi_saveas(femfile);
meshsize = 0.2e-3;
minAngle = 10; % fine : 30, big : 10
mi_probdef(fr,'meters','planar',1E-08,0,minAngle,1);


%% Material list

f_femm_addmaterial('material_name','air');
f_femm_addmaterial('material_name','compos','mur',mur_plate,'sigma',sig_plate);
f_femm_addmaterial('material_name','copper','mur',1,'sigma',sig_coil);

%% Trace out the domains

draw2d = [];
draw2d = f_femm_draw_straightrect(draw2d,'id_draw2d','plate',...
            'center',[0 -y_plate/2],...
            'r_len',x_plate,'theta_len',y_plate);
draw2d = f_femm_draw_straightrect(draw2d,'id_draw2d','agap',...
            'center',[0 agap/2],...
            'r_len',x_plate,'theta_len',agap);
draw2d = f_femm_draw_straightrect(draw2d,'id_draw2d','coil',...
            'center',[0 agap+y_coil/2],...
            'r_len',x_coil,'theta_len',y_coil);
draw2d = f_femm_draw_straightrect(draw2d,'id_draw2d','air',...
            'center',[0 0],...
            'r_len',x_airbox,'theta_len',y_airbox);

%% domain attribution
f_femm_set_block(draw2d,'id_draw2d','air'  ,'method','bottomleft','block_name','air'  ,'meshsize',20*meshsize);
f_femm_set_block(draw2d,'id_draw2d','agap' ,'method','center','block_name','air'  ,'meshsize',meshsize);
f_femm_set_block(draw2d,'id_draw2d','plate','method','center','block_name','compos','meshsize',meshsize, ...
                        'in_circuit','I0','nb_turns',1);
f_femm_set_block(draw2d,'id_draw2d','coil' ,'method','center','block_name','copper' ,'meshsize',meshsize, ...
                        'in_circuit',Iphase,'nb_turns',nb_turns);

%% Boundary conditions
f_femm_setbc_rect([0 0],[x_airbox y_airbox],'A=0');


%% Properties of boundary conditions and circuit

mi_addboundprop('A=0',0,0,0,0,0,0,0,0,0);
mi_addcircprop('IA',Imax,1);
mi_addcircprop('I0',0,1);

%% Mailler
mi_createmesh;
mi_zoomnatural;

%% Solve
tic
mi_analyze(1);
mi_loadsolution;
mi_zoomnatural;
toc



%%
dom2d = [];
dom2d = f_load_femm_mesh(dom2d,'meshfile',meshfile);
figure; f_view_mesh_2d(dom2d,'plotter','champ3d');

%% 


%   Post-processing



%--- J surface plate
nbp = 100;
esurf  = 1e-4; 
x_line = linspace(-x_plate/2+1e-6,x_plate/2-1e-6,nbp);
y_line = -(esurf/2) .* ones(1,nbp);
J_co1 = zeros(1,nbp);
for i = 1:nbp
     J_co1(i) = mo_getj(x_line(i),y_line(i)) * 1e6;
end
figure
plot(x_line,-real(J_co1),'-or','DisplayName','real(J) sim2D-surface-plate'); hold on
plot(x_line,-imag(J_co1),'-xr','DisplayName','imag(J) sim2D-surface-plate'); hold on

%% circuit properties

cirpro  = mo_getcircuitproperties('IA');
Current = cirpro(1);
Voltage = cirpro(2);
Flux    = cirpro(3);
Lind    = Flux/Current;


