% ---------------- TEST MULTIPLE IMAGES -----------------------------------
% Inf line current at cI = [xI, yI]
% Inf long but finite thick and width plate 
%   of dim : tP x wP centered at [0, -tP/2]

% close all
clear all
clc


load dataAN_06.mat
dmax = dataAN.dmax;
d0   = dataAN.d0;
c0   = dataAN.c0;
mur  = dataAN.mur;
I0   = dataAN.I0;
tP   = dataAN.tP;
wP   = dataAN.wP;
dP   = dataAN.dP; 
agap = dataAN.agap;
px = dataAN.px;
py = dataAN.py; py(abs(py) <= 1e-6) = -tP/2;
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
draw.Tx_fer_01  = FEMM2dRectangle('cen_x',0,'cen_y',-tP/2,'len_x',wP,'len_y',tP);
draw.Tx_fer_02  = FEMM2dRectangle('cen_x',0,'cen_y',-tP/2+tP+dP,'len_x',wP,'len_y',tP);
% ---
xsizefmesh = max(2.1*max(abs(py)),10*d0);
ysizefmesh = xsizefmesh;
draw.finmesh = FEMM2dRectangle('cen_x',0,'cen_y',dP/2,'len_x',1.1*wP,'len_y',2.2*(tP+dP/2));
draw.Tx_coil = FEMM2dCircle('cen_x',c0(1),'cen_y',c0(2),'r',1e-3,'max_angle_len',5);

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
WPT_CirCoil.add_draw('id_draw','Tx_fer_01','draw',draw.Tx_fer_01);
WPT_CirCoil.add_draw('id_draw','Tx_fer_02','draw',draw.Tx_fer_02);
WPT_CirCoil.add_draw('id_draw','finmesh','draw',draw.finmesh);
% ---
WPT_CirCoil.add_draw('id_draw','Tx_coil','draw',draw.Tx_coil);


% --- add box (airbox, domain limits)
WPT_CirCoil.add_box('id_box','airbox','draw',draw.airbox);
% --- set dom (domain = region)
% --- air
msizefmesh = 1.5e-3;
WPT_CirCoil.set_dom('id_dom','airbox','id_material','air',...
                     'id_draw','airbox',...
                     'choosed_by','top',...
                     'mesh_size',50e-3);
WPT_CirCoil.set_dom('id_dom','finmesh','id_material','air',...
                     'id_draw','finmesh',...
                     'choosed_by','top',...
                     'mesh_size',msizefmesh);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_fer_01','id_material','ferrite',...
                     'id_draw','Tx_fer_01',...
                     'choosed_by','center',...
                     'mesh_size',msizefmesh);
WPT_CirCoil.set_dom('id_dom','Tx_fer_02','id_material','ferrite',...
                     'id_draw','Tx_fer_02',...
                     'choosed_by','center',...
                     'mesh_size',msizefmesh);
% ---
WPT_CirCoil.set_dom('id_dom','Tx_coil','id_material','TxCoil', ...
        'id_draw','Tx_coil', ...
        'id_coil','Tx_coil','mesh_size',0.1e-3);
% ---

% --- set bound (apply boundary condition)
WPT_CirCoil.set_bound('id_bound','open','id_bc','open',...
    'id_box','airbox','choosed_by','all');

% --- solve
WPT_CirCoil.circuit.Tx.i = dataAN.I0;
WPT_CirCoil.solve;
% WPT_CirCoil.getdata;


%%
% nbp = 2000;
% px  = linspace(-wP/2,+wP/2,nbp);
% py  = -0.5e-3.*ones(1,nbp);
% py  = -(tP-0.5e-3).*ones(1,nbp);
% py  = -tP/2.*ones(1,nbp);
% py = agap/2 .* ones(1,nbp);
% ---
BFEM_01 = WPT_CirCoil.getB([px; py]);

%%
figure
subplot(121)
plot(px, (BFEM_01(1,:)), "r-", "LineWidth", 2, 'DisplayName', 'FEM'); hold on
subplot(122)
plot(px, (BFEM_01(2,:)), "r-", "LineWidth", 2, 'DisplayName', 'FEM'); hold on
legend;

