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

close all
clear all
clc



l_coef = unique([linspace(1,2,20) linspace(2,5,20)]);
nbTest = length(l_coef);
flux = zeros(4,nbTest);

for itest = 1:nbTest

%% Data
ro = 300e-3;
ri = 50e-3;
% ---
% radius of the each bundle (group of strands)
Tx_wire_rBundle  = 5e-3;
Rx_wire_rBundle  = 5e-3;
% ---
Tx_nb_turn = 2;
Tx_I = 0;
Tx_r_in = 5e-3; 
Tx_r_ex = ro;
Tx_agap = 5e-3;  % coil and ferrite
Tx_fer_r_in = Tx_r_in;
Tx_fer_r_ex = Tx_wire_rBundle + l_coef(itest)*Tx_r_ex;
Tx_fer_t    = 20e-3;
% ---
Rx_nb_turn = Tx_nb_turn;
Rx_I = 0;
Rx_r_in = Tx_r_in;
Rx_r_ex = Tx_r_ex; %
Rx_agap = Tx_agap;  % coil and ferrite
Rx_fer_r_in = Tx_fer_r_in;
Rx_fer_r_ex = Tx_fer_r_ex;
Rx_fer_t    = Tx_fer_t;
% ---
airgap = 200e-3;   % airgap between Tx and Rx (coil to coil)
% ---
sigmaCu = 5.8e7;
murFerrite  = 1000;
sigmaFerrite = 0;
phi_hx = 0.7346;
phi_hy = phi_hx;
% ---
fr = 0; % frequency
%% Derived parameters
% ---
Tx_wire_diameter = 71e-6; % for Litz wire if needed
Tx_wire_nbStrand = floor(pi*Tx_wire_rBundle^2 / (pi*Tx_wire_diameter^2/4)); % for Litz wire if needed
Rx_wire_diameter = 71e-6; % for Litz wire if needed
Rx_wire_nbStrand = floor(pi*Rx_wire_rBundle^2 / (pi*Rx_wire_diameter^2/4)); % for Litz wire if needed
% ---
Tx_d = ro - ri;  % distance between turns
Rx_d = ro - ri;  % distance between turns
% ---
if (Tx_d < 0) || (Rx_d < 0)
    error('Impossible distance between turns');
end
% ---
Tx_section = pi * Tx_wire_rBundle^2;
Rx_section = pi * Rx_wire_rBundle^2;
Tx_Js = Tx_I / Tx_section;
Rx_Js = Rx_I / Rx_section;

R_bound = 2 * max([Tx_r_ex, Tx_fer_r_ex, Rx_r_ex, Rx_fer_r_ex, airgap]);

%% Prepare : materials / circuit / BC / draw
%
%
%
%
% -------------------------------------------------------------------------

% --- Material list
% (we don't use all but prepare the list)
mat.air      = FEMM2dMaterial();
mat.ferrite  = FEMM2dMaterial('mur',murFerrite,'sigma',sigmaFerrite,...
                              'phi_hx',phi_hx,'phi_hy',phi_hy);
mat.Litzwire = FEMM2dWire('wire_type','no_loss',...
    'sigma',0,'nb_strand',Tx_wire_nbStrand,'wire_diameter',Tx_wire_diameter);

% --- Circuit list
for i = 1:Tx_nb_turn
    cirname = ['Tx_phase_' num2str(i)];
    cir.(cirname) = FEMM2dCircuit('i',0,'turn_connexion','series');
end
for i = 1:Rx_nb_turn
    cirname = ['Rx_phase_' num2str(i)];
    cir.(cirname) = FEMM2dCircuit('i',0,'turn_connexion','series');
end

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
    'ref_point',[0 -(airgap/2 + 2*Tx_wire_rBundle + Tx_agap + Tx_fer_t/2)],...
    'cen_x',(Tx_fer_r_in + Tx_fer_r_ex)/2,'cen_y',0,...
    'len_x',Tx_fer_r_ex - Tx_fer_r_in,'len_y',Tx_fer_t);
draw.Rx_fer = FEMM2dRectangle(...
    'ref_point',[0 +(airgap/2 + 2*Rx_wire_rBundle + Rx_agap + Rx_fer_t/2)],...
    'cen_x',(Rx_fer_r_in + Rx_fer_r_ex)/2,'cen_y',0,...
    'len_x',Rx_fer_r_ex - Rx_fer_r_in,'len_y',Rx_fer_t);
% ---
draw.fine_mesh = FEMM2dRectangle(...
    'ref_point',[0 0],...
    'cen_x',(Tx_fer_r_in/2 + Tx_fer_r_ex)/2,'cen_y',0,...
    'len_x',Tx_fer_r_ex - Tx_fer_r_in/2,'len_y',airgap + 2*Rx_wire_rBundle + ...
              2*Tx_wire_rBundle + Rx_agap + Tx_agap + Rx_fer_t + Tx_fer_t + Tx_fer_t);
% ---
for i = 1:Tx_nb_turn
    d2nextTurn = (i-1) * Tx_d;
    draw.Tx_coil{i} = FEMM2dCircle(...
        'ref_point',[Tx_r_ex, -(airgap/2 + Tx_wire_rBundle)],...
        'cen_x',-d2nextTurn,'cen_y',0,...
        'r',Tx_wire_rBundle,'max_angle_len',10);
end
% ---
for i = 1:Rx_nb_turn
    d2nextTurn = (i-1) * Rx_d;
    draw.Rx_coil{i} = FEMM2dCircle(...
        'ref_point',[Tx_r_ex, +(airgap/2 + Rx_wire_rBundle)],...
        'cen_x',-d2nextTurn,'cen_y',0,...
        'r',Rx_wire_rBundle,'max_angle_len',10);
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
WPT_CirCoil.add_material('id_material','Litzwire','material',mat.Litzwire);

% --- add bc
WPT_CirCoil.add_bc('id_bc','open','bc',bc.open);
WPT_CirCoil.add_bc('id_bc','symm','bc',bc.dAdn0);

% --- add circuit
for i = 1:Tx_nb_turn
    id_circ = ['Tx_phase_' num2str(i)];
    cirname = ['Tx_phase_' num2str(i)];
    WPT_CirCoil.add_circuit('id_circuit',id_circ,'circuit',cir.(cirname));
end
for i = 1:Rx_nb_turn
    id_circ = ['Rx_phase_' num2str(i)];
    cirname = ['Rx_phase_' num2str(i)];
    WPT_CirCoil.add_circuit('id_circuit',id_circ,'circuit',cir.(cirname));
end

% --- add coil
for i = 1:Tx_nb_turn
    id_coil = ['TxCoil_' num2str(i)];
    cirname = ['Tx_phase_' num2str(i)];
    WPT_CirCoil.add_iscoil('id_coil',id_coil,'id_circuit',cirname,...
    'id_wire','Litzwire','nb_turn',1,'pole',+1);
end
for i = 1:Rx_nb_turn
    id_coil = ['RxCoil_' num2str(i)];
    cirname = ['Rx_phase_' num2str(i)];
    WPT_CirCoil.add_iscoil('id_coil',id_coil,'id_circuit',cirname,...
    'id_wire','Litzwire','nb_turn',1,'pole',+1);
end

% --- add draw
WPT_CirCoil.add_draw('id_draw','Tx_fer','draw',draw.Tx_fer);
WPT_CirCoil.add_draw('id_draw','Rx_fer','draw',draw.Rx_fer);
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
                     'choosed_by','center','mesh_size',10e-3);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_fer','id_material','ferrite',...
                     'id_draw','Tx_fer',...
                     'choosed_by','center',...
                     'mesh_size',10e-3);
WPT_CirCoil.set_dom('id_dom','Rx_fer','id_material','ferrite',...
                     'id_draw','Rx_fer',...
                     'choosed_by','center',...
                     'mesh_size',10e-3);
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
WPT_CirCoil.circuit.Tx_phase_1.i = 1;
% WPT_CirCoil.circuit.Tx_phase_2.i = 1;
% WPT_CirCoil.circuit.Rx_phase_1.i = 1;
% WPT_CirCoil.circuit.Rx_phase_2.i = 1;

WPT_CirCoil.solve;
WPT_CirCoil.getdata;

%%
for i = 1:Tx_nb_turn
    id_circ = ['Tx_phase_' num2str(i)];
    WPT_CirCoil.circuit.(id_circ).get_quantity;
    flux(i,itest) = WPT_CirCoil.circuit.(id_circ).quantity.flux_linkage;
end
for i = 1:Rx_nb_turn
    id_circ = ['Rx_phase_' num2str(i)];
    WPT_CirCoil.circuit.(id_circ).get_quantity;
    flux(i+2,itest) = WPT_CirCoil.circuit.(id_circ).quantity.flux_linkage;
end

%%

end

% save X_ISSUE_FEM2d_V5a_ex_to_in_ri50 l_coef flux
save X_ISSUE_FEM2d_V5a_in_to_ex_ri50 l_coef flux

return
%%
figure
plot(l_coef,flux(1,:),'DisplayName','Tx-ex-coil'); hold on
plot(l_coef,flux(2,:),'DisplayName','Tx-in-coil');
plot(l_coef,flux(3,:),'DisplayName','Rx-ex-coil');
plot(l_coef,flux(4,:),'DisplayName','Rx-in-coil');

%%
figure
plot(l_coef,flux(1,:)./flux(1,end),'DisplayName','Tx-ex-coil'); hold on
plot(l_coef,flux(2,:)./flux(2,end),'DisplayName','Tx-in-coil');
plot(l_coef,flux(3,:)./flux(3,end),'DisplayName','Rx-ex-coil');
plot(l_coef,flux(4,:)./flux(4,end),'DisplayName','Rx-in-coil');







