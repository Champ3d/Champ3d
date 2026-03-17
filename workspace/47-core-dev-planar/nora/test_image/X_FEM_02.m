% ---------------- TEST MULTIPLE IMAGES -----------------------------------
% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

% close all
clear all
clc


load dataANA.mat
c0   = dataANA.c0;
mur  = dataANA.mur;
I0   = dataANA.I0;
tP   = dataANA.tP;
wP   = dataANA.wP;
agap = dataANA.agap;
px = dataANA.px;
py = dataANA.py;
pxNoyau=dataANA.pxNoyau;
 pyNoyau=dataANA.pyNoyau ;
R_bound = 2*max([tP,wP,agap]);
%% Prepare : materials / circuit / BC / draw
%
%
%
%
% -------------------------------------------------------------------------

% --- Material list
% (we don't use all but prepare the list)
mat.air      = FEMM2dMaterial();
mat.ferrite  = FEMM2dMaterial('mur',mur,'sigma',0);
mat.Litzwire = FEMM2dWire('wire_type','no_loss','sigma',0);

% --- Circuit list
cir.Tx = FEMM2dCircuit('i',I0,'turn_connexion','series');

% --- BC (boundary condition) list
bc.A0    = FEMM2dBCfixedA('a0',0);
bc.dAdn0 = FEMM2dBCmixed('c0',0,'c1',0);
bc.open  = FEMM2dBCopen('ro',R_bound);

% --- Draw list
% --- airbox
draw.airbox  = FEMM2dCircle('cen_x',0,'cen_y',0,'r',R_bound);
draw.Tx_fer  = FEMM2dRectangle('cen_x',0,'cen_y',-tP/2,'len_x',wP,'len_y',tP);
draw.finmesh = FEMM2dRectangle('cen_x',0,'cen_y',agap,'len_x',wP,'len_y',2*agap);
draw.Tx_coil = FEMM2dCircle('cen_x',c0(1),'cen_y',c0(2),'r',0.1e-3,'max_angle_len',2);

%% Build FEMM model
%  Create FEMM object
%  and add elements
%
%
% -------------------------------------------------------------------------
WPT_CirCoil = FEMM2dMag('id_project','WPT_CirCoil','problem_type','planar','fr',0,...
    'acsolver','newton','unit','meters','min_angle',20,'depth',1);

% --- add materials
WPT_CirCoil.add_material('id_material','air','material',mat.air);
WPT_CirCoil.add_material('id_material','ferrite','material',mat.ferrite);
WPT_CirCoil.add_material('id_material','Litzwire','material',mat.Litzwire);

% --- add bc
WPT_CirCoil.add_bc('id_bc','open','bc',bc.open);

% --- add circuit
WPT_CirCoil.add_circuit('id_circuit','Tx','circuit',cir.Tx);

% --- add coil
WPT_CirCoil.add_iscoil('id_coil','Tx_coil','id_circuit','Tx',...
    'id_wire','Litzwire','nb_turn',1,'pole',+1);

% --- add draw
WPT_CirCoil.add_draw('id_draw','Tx_fer','draw',draw.Tx_fer);
WPT_CirCoil.add_draw('id_draw','finmesh','draw',draw.finmesh);
% ---
WPT_CirCoil.add_draw('id_draw','Tx_coil','draw',draw.Tx_coil);


% --- add box (airbox, domain limits)
WPT_CirCoil.add_box('id_box','airbox','draw',draw.airbox);
% --- set dom (domain = region)
% --- air
WPT_CirCoil.set_dom('id_dom','airbox','id_material','air',...
                     'id_draw','airbox',...
                     'choosed_by','top',...
                     'mesh_size',5e-3);
WPT_CirCoil.set_dom('id_dom','finmesh','id_material','air',...
                     'id_draw','finmesh',...
                     'choosed_by','top',...
                     'mesh_size',0.1e-3);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_fer','id_material','ferrite',...
                     'id_draw','Tx_fer',...
                     'choosed_by','center',...
                     'mesh_size',1e-3);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_coil','id_material','TxCoil', ...
        'id_draw','Tx_coil', ...
        'id_coil','Tx_coil','mesh_size',0.1e-3);
% ---

% --- set bound (apply boundary condition)
WPT_CirCoil.set_bound('id_bound','open','id_bc','open',...
    'id_box','airbox','choosed_by','all');

% --- solve
WPT_CirCoil.circuit.Tx.i = dataANA.I0;
WPT_CirCoil.solve;
WPT_CirCoil.getdata;


%%

BFEM_01 = WPT_CirCoil.getB([px; py]);
BFEM_02 = WPT_CirCoil.getB([pxNoyau; pyNoyau]);

%%
% figure
% plot(px, vecnorm(BFEM_01), "bo", "LineWidth", 2, 'DisplayName', 'FEM_1'); hold on
% legend;
%
figure
plot(pxNoyau, vecnorm(BFEM_02), "ro", "LineWidth", 2, 'DisplayName', 'FEM_0'); hold on
legend;