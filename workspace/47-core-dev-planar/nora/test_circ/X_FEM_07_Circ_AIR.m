%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

%close all
clear all
clc

load dataAN_07.mat

%% Data
% --- 
Tx_nb_turn = 1;
Tx_I = dataAN.I1;
Tx_r = dataAN.rtx;
Tx_agap = dataAN.Tx_agap;  % coil and ferrite
Tx_fer_r = dataAN.rfertx;
Tx_fer_t = dataAN.tfer;
Tx_mbl_t = Tx_fer_t;
Tx_mbl_ri = Tx_fer_r;
Tx_mbl_ro = Tx_fer_r + dataAN.dmblin;
mur_mbl = 2000;
% ---
Rx_nb_turn = 1;
Rx_I = dataAN.I2;
Rx_r = Tx_r; %
Rx_agap = dataAN.Rx_agap;  % coil and ferrite
Rx_fer_r = dataAN.rferrx;
Rx_fer_t = Tx_fer_t;
Rx_mbl_t = Tx_fer_t;
Rx_mbl_ri = Tx_mbl_ri;
Rx_mbl_ro = Tx_mbl_ro;
% ---
airgap = dataAN.agap;   % airgap between Tx and Rx (coil to coil)
% ---
sigmaCu = 5.8e7;
murFerrite  = dataAN.mur;
sigmaFerrite = 0;
phi_hx = 0.7346;
phi_hy = phi_hx;
% ---
fr = 0; % frequency
%% Derived parameters
% ---
% radius of the each bundle (group of strands)
Tx_wire_rBundle  = dataAN.rwire;
Rx_wire_rBundle  = dataAN.rwire;
% ---
Tx_section = pi * Tx_wire_rBundle^2;
Rx_section = pi * Rx_wire_rBundle^2;
Tx_Js = Tx_I / Tx_section;
Rx_Js = Rx_I / Rx_section;

R_bound = 3 * max([Tx_r, Tx_fer_r, Rx_r, Rx_fer_r, airgap, Tx_mbl_ro]);

%% Prepare : materials / circuit / BC / draw
%
%
%
%
% -------------------------------------------------------------------------

% --- Material list
% (we don't use all but prepare the list)
mat.air      = FEMM2dMaterial();
mat.ferrite  = FEMM2dMaterial('mur',murFerrite);
mat.mblin    = FEMM2dMaterial('mur',mur_mbl);
mat.Litzwire = FEMM2dWire('wire_type','no_loss','sigma',0);

% --- Circuit list
cir.Tx_phase_1 = FEMM2dCircuit('i',Tx_I,'turn_connexion','series');
cir.Rx_phase_1 = FEMM2dCircuit('i',Rx_I,'turn_connexion','series');

% --- BC (boundary condition) list
bc.A0    = FEMM2dBCfixedA('a0',0);
bc.dAdn0 = FEMM2dBCmixed('c0',0,'c1',0);
bc.open  = FEMM2dBCopen('ro',R_bound);

% --- Draw list
% --- airbox
draw.airbox = FEMM2dHalfDisk('base_x',0,'base_y',0,'arclen',180,...
                             'r',R_bound,'orientation',0);
% ---
draw.Tx_fer = FEMM2dRectangle(...
    'ref_point',[0 -(airgap/2 + Tx_agap + Tx_fer_t/2)],...
    'cen_x',Tx_fer_r/2,'cen_y',0,...
    'len_x',Tx_fer_r,'len_y',Tx_fer_t);
draw.Rx_fer = FEMM2dRectangle(...
    'ref_point',[0 +(airgap/2 + Rx_agap + Rx_fer_t/2)],...
    'cen_x',Rx_fer_r/2,'cen_y',0,...
    'len_x',Rx_fer_r,'len_y',Rx_fer_t);
% ---
draw.Tx_mblin = FEMM2dRectangle(...
    'ref_point',[0 -(airgap/2 + Tx_agap + Tx_fer_t + Tx_mbl_t/2)],...
    'cen_x',(Tx_mbl_ro + Tx_mbl_ri)/2,'cen_y',0,...
    'len_x',Tx_mbl_ro - Tx_mbl_ri,'len_y',Tx_mbl_t);
draw.Rx_mblin = FEMM2dRectangle(...
    'ref_point',[0 +(airgap/2 + Rx_agap + Rx_fer_t + Rx_mbl_t/2)],...
    'cen_x',(Rx_mbl_ro + Rx_mbl_ri)/2,'cen_y',0,...
    'len_x',Rx_mbl_ro - Rx_mbl_ri,'len_y',Rx_mbl_t);
% ---
draw.fine_mesh = FEMM2dRectangle(...
    'ref_point',[0 0],...
    'cen_x',(1.2*Tx_mbl_ro)/2,'cen_y',0,...
    'len_x',1.2*Tx_mbl_ro,'len_y',1.1*(airgap + Rx_agap + Tx_agap + Rx_fer_t + Tx_fer_t + Rx_mbl_t + Tx_mbl_t));
% ---
for i = 1:Tx_nb_turn
    d2nextTurn = (i-1) * 0;
    draw.Tx_coil{i} = FEMM2dCircle(...
        'ref_point',[Tx_r, -airgap/2],...
        'cen_x',-d2nextTurn,'cen_y',0,...
        'r',Tx_wire_rBundle,'max_angle_len',2);
end
% ---
for i = 1:Rx_nb_turn
    d2nextTurn = (i-1) * 0;
    draw.Rx_coil{i} = FEMM2dCircle(...
        'ref_point',[Tx_r, +airgap/2],...
        'cen_x',-d2nextTurn,'cen_y',0,...
        'r',Rx_wire_rBundle,'max_angle_len',2);
end

%% Build FEMM model
%  Create FEMM object
%  and add elements
%
%
% -------------------------------------------------------------------------
WPT_CirCoil = FEMM2dMag('id_project','WPT_CirCoil','problem_type','axi','fr',fr,...
    'acsolver','newton','unit','meters','min_angle',20);

% --- add materials
WPT_CirCoil.add_material('id_material','air','material',mat.air);
WPT_CirCoil.add_material('id_material','ferrite','material',mat.ferrite);
WPT_CirCoil.add_material('id_material','mblin','material',mat.mblin);
WPT_CirCoil.add_material('id_material','Litzwire','material',mat.Litzwire);

% --- add bc
WPT_CirCoil.add_bc('id_bc','open','bc',bc.open);
WPT_CirCoil.add_bc('id_bc','symm','bc',bc.dAdn0);

% --- add circuit
WPT_CirCoil.add_circuit('id_circuit','Tx_phase_1','circuit',cir.Tx_phase_1);
WPT_CirCoil.add_circuit('id_circuit','Rx_phase_1','circuit',cir.Rx_phase_1);

% --- add coil
WPT_CirCoil.add_iscoil('id_coil','TxCoil_1','id_circuit','Tx_phase_1',...
    'id_wire','Litzwire','nb_turn',1,'pole',+1);
WPT_CirCoil.add_iscoil('id_coil','RxCoil_1','id_circuit','Rx_phase_1',...
    'id_wire','Litzwire','nb_turn',1,'pole',+1);

% --- add draw
WPT_CirCoil.add_draw('id_draw','Tx_fer','draw',draw.Tx_fer);
WPT_CirCoil.add_draw('id_draw','Rx_fer','draw',draw.Rx_fer);
% ---
WPT_CirCoil.add_draw('id_draw','Tx_mblin','draw',draw.Tx_mblin);
WPT_CirCoil.add_draw('id_draw','Rx_mblin','draw',draw.Rx_mblin);
% ---
for i = 1:Tx_nb_turn
    id_turn = ['Tx_coil_turn_' num2str(i)];
    WPT_CirCoil.add_draw('id_draw',id_turn,'draw',draw.Tx_coil{i});
end
% ---
for i = 1:Rx_nb_turn
    id_turn = ['Rx_coil_turn_' num2str(i)];
    WPT_CirCoil.add_draw('id_draw',id_turn,'draw',draw.Rx_coil{i});
end

% --- add box (airbox, domain limits)
WPT_CirCoil.add_box('id_box','airbox','draw',draw.airbox);
WPT_CirCoil.add_draw('id_draw','fine_mesh','draw',draw.fine_mesh);
% --- set dom (domain = region)
% --- air
WPT_CirCoil.set_dom('id_dom','airbox','id_material','air',...
                     'id_draw','airbox',...
                     'choosed_by','top');
WPT_CirCoil.set_dom('id_dom','fine_mesh','id_material','air',...
                     'id_draw','fine_mesh',...
                     'choosed_by','center','mesh_size',2e-3);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_fer','id_material','ferrite',...
                     'id_draw','Tx_fer',...
                     'choosed_by','center',...
                     'mesh_size',2e-3);
WPT_CirCoil.set_dom('id_dom','Rx_fer','id_material','ferrite',...
                     'id_draw','Rx_fer',...
                     'choosed_by','center',...
                     'mesh_size',2e-3);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_mblin','id_material','mblin',...
                     'id_draw','Tx_mblin',...
                     'choosed_by','center',...
                     'mesh_size',2e-3);
WPT_CirCoil.set_dom('id_dom','Rx_mblin','id_material','mblin',...
                     'id_draw','Rx_mblin',...
                     'choosed_by','center',...
                     'mesh_size',2e-3);
% ---
for i = 1:Tx_nb_turn
    id_turn = ['Tx_coil_turn_' num2str(i)];
    id_coil = ['TxCoil_' num2str(i)];
    WPT_CirCoil.set_dom('id_dom',id_turn,'id_material','TxCoil', ...
        'id_draw',id_turn, ...
        'id_coil',id_coil,'mesh_size',Tx_wire_rBundle/5);
end
% ---
for i = 1:Rx_nb_turn
    id_turn = ['Rx_coil_turn_' num2str(i)];
    id_coil = ['RxCoil_' num2str(i)];
    WPT_CirCoil.set_dom('id_dom',id_turn,'id_material','RxCoil', ...
        'id_draw',id_turn, ...
        'id_coil',id_coil,'mesh_size',Rx_wire_rBundle/5);
end

% --- set bound (apply boundary condition)
WPT_CirCoil.set_bound('id_bound','symm','id_bc','symm',...
    'id_box','airbox','choosed_by','bottom');
WPT_CirCoil.set_bound('id_bound','open','id_bc','open',...
    'id_box','airbox','choosed_by','top');


% --- solve
WPT_CirCoil.circuit.Tx_phase_1.i = dataAN.I1;
WPT_CirCoil.circuit.Rx_phase_1.i = dataAN.I2;
WPT_CirCoil.solve;
% WPT_CirCoil.getdata;

% ---
WPT_CirCoil.circuit.Tx_phase_1.get_quantity
WPT_CirCoil.circuit.Tx_phase_1.quantity
WPT_CirCoil.circuit.Rx_phase_1.get_quantity
WPT_CirCoil.circuit.Rx_phase_1.quantity

%% A in AIR
nbp = 1000;
px  = linspace(0,Tx_r - Tx_wire_rBundle,nbp);
% ---
py  = -(airgap/2) .* ones(1,nbp);
AFEM_01 = WPT_CirCoil.getA([px; py]);
% ---
py  = +(airgap/2) .* ones(1,nbp);
% py  = 0 .* ones(1,nbp);
AFEM_02 = WPT_CirCoil.getA([px; py]);

figure
plot(px, AFEM_01, "r", "LineWidth", 1, "DisplayName", "A - FEM"); hold on
plot(px, AFEM_02, "r", "LineWidth", 1, "DisplayName", 'A - FEM'); hold on
legend;

%% A in FER
nbp = 1000;
px  = linspace(0,Tx_fer_r,nbp);
% ---
py  = -(airgap/2 + Tx_agap + Tx_fer_t/2) .* ones(1,nbp);
AFEM_01 = WPT_CirCoil.getA([px; py]);
% ---
py  = -(airgap/2 + Tx_agap + Tx_fer_t/20) .* ones(1,nbp);
% py  = 0 .* ones(1,nbp);
AFEM_02 = WPT_CirCoil.getA([px; py]);

figure
plot(px, AFEM_01, "r", "LineWidth", 1, "DisplayName", "A - FEM"); hold on
plot(px, AFEM_02, "r", "LineWidth", 1, "DisplayName", 'A - FEM'); hold on
legend;

%% B in Air
nbp = 1000;
px  = linspace(0,Tx_r - Tx_wire_rBundle,nbp);
% ---
py  = -(airgap/2) .* ones(1,nbp);
BFEM_01 = WPT_CirCoil.getB([px; py]);

figure
subplot(121)
plot(px, (BFEM_01(1,:)), "r-", "LineWidth", 2, 'DisplayName', 'Bx - FEM'); hold on
subplot(122)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 2, 'DisplayName', 'By - FEM'); hold on
legend;

%% B in Air
nbp = 1000;
px  = linspace(0,Tx_r - Tx_wire_rBundle,nbp);
% ---
py  = +(airgap/2) .* ones(1,nbp);
BFEM_01 = WPT_CirCoil.getB([px; py]);

figure
subplot(121)
plot(px, (BFEM_01(1,:)), "r-", "LineWidth", 2, 'DisplayName', 'Bx - FEM'); hold on
subplot(122)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 2, 'DisplayName', 'By - FEM'); hold on
legend;

%% Bz in Air
nbp = 1000;
px  = linspace(0,Tx_r - Tx_wire_rBundle,nbp);
% ---
py  = -(airgap/2) .* ones(1,nbp);
BFEM_01 = WPT_CirCoil.getB([px; py]);
py  = +(airgap/2) .* ones(1,nbp);
BFEM_02 = WPT_CirCoil.getB([px; py]);

figure
subplot(121)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 1, 'DisplayName', 'Bx - FEM'); hold on
subplot(122)
plot(px, (BFEM_02(2,:)), "r-", "LineWidth", 1, 'DisplayName', 'By - FEM'); hold on
legend;

%% B in FER
nbp = 100;
px  = linspace(0,Tx_fer_r,nbp);
% ---
py  = -(airgap/2 + Tx_agap + Tx_fer_t/2) .* ones(1,nbp);
BFEM_01 = WPT_CirCoil.getB([px; py]);

figure
subplot(121)
plot(px, (BFEM_01(1,:)), "r-", "LineWidth", 2, 'DisplayName', 'Bx - FEM'); hold on
subplot(122)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 2, 'DisplayName', 'By - FEM'); hold on
legend;

%% B in FER
nbp = 100;
px  = linspace(0,Tx_fer_r,nbp);
% ---
py  = -(airgap/2 + Tx_agap + Tx_fer_t/20) .* ones(1,nbp);
BFEM_01 = WPT_CirCoil.getB([px; py]);

figure
subplot(121)
plot(px, (BFEM_01(1,:)), "r-", "LineWidth", 2, 'DisplayName', 'Bx - FEM'); hold on
subplot(122)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 2, 'DisplayName', 'By - FEM'); hold on
legend;
