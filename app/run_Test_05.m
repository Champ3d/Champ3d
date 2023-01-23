%


%   ECHOS2
%   Simulation soudage
%   2023, HK.B


%
%%
clc
clear
close all

addpath(genpath('./Core'));
startup;
%--------------------------------------------------------------------------
x0 = 50e-3;
xi = 8e-3;

%---
mesOpt.x{1} = {x0,10,'log-'};
mesOpt.x{2} = {xi,8,'lin'};
mesOpt.x{3} = {x0,10,'log+'};
%--------------------------------------------------------------------------
eiso1 = 50e-3;
eins  = 1e-3;
eiso2 = 1e-3;
eLSP  = 100e-6;
eplate = 1e-3;
agap  = 2e-3;
eind  = 8e-3;
hind  = 50e-3;
%---
mesOpt.y{1} = {eiso1,5,'log-'};
mesOpt.y{2} = {eins,2,'lin'};
mesOpt.y{3} = {eiso2,2,'lin'};
mesOpt.y{4} = {eLSP,1,'lin'};
mesOpt.y{5} = {eplate,8,'log-'};
mesOpt.y{6} = {agap,4,'lin'};
mesOpt.y{7} = {eind,5,'lin'};
mesOpt.y{8} = {hind,10,'log+'};
%--------------------------------------------------------------------------
% -------------------------------------------------------------------------
[p2d, t2d, ~, ~, ~] = f_make_mesh_xy(mesOpt);
nb_p = size(p2d,2);
nb_t = size(t2d,2);
% -------------------------------------------------------------------------
iElem_E60 = f_find_dom_xy(t2d,{[1:3]},{[1 3]}); %
iElem_Ins = f_find_dom_xy(t2d,{[1:3]},{[2]});
iElem_LSP = f_find_dom_xy(t2d,{[1:3]},{[4]});
iElem_Plate = f_find_dom_xy(t2d,{[1:3]},{[5]});
iElem_Face = f_find_dom_xy(t2d,{[2]},{[7]}); 
iElem_Bras = f_find_dom_xy(t2d,{[2]},{[8]}); 
% -------------------------------------------------------------------------
figure
f_view_meshquad(p2d,t2d,iElem_E60,f_randcolor); hold on
f_view_meshquad(p2d,t2d,iElem_Ins,f_randcolor); hold on
f_view_meshquad(p2d,t2d,iElem_LSP,f_randcolor); hold on
f_view_meshquad(p2d,t2d,iElem_Plate,f_randcolor); hold on
f_view_meshquad(p2d,t2d,iElem_Face,f_randcolor); hold on
f_view_meshquad(p2d,t2d,iElem_Bras,f_randcolor); hold on


%% ------------------------------------------------------------------------

t2d(6:7,:) = []; 
t2d(5,:) = 1;

t2d(5,iElem_E60) = 2;
t2d(5,iElem_Ins) = 3;
t2d(5,iElem_LSP) = 4;
t2d(5,iElem_Plate) = 1000;
t2d(5,iElem_Face) = 6;
t2d(5,iElem_Bras) = 7;

%% ------------------------------------------------------------------------

dom2d.mesh.node = p2d;
dom2d.mesh.elem = t2d;
clear p2d t2d

figure; f_view_mesh_2d(dom2d,'plotter','iCombo');

%% ------------------------------------------------------------------------
dz = 8e-3; % easier if = inductor thickness
hAir = 10e-3;
hIndOut = 5 * dz;
LPlate = 10 * dz; %2*x0 + xi;
nbdz = (LPlate + hIndOut)/dz;
if abs(mod(nbdz,1)) > 1e-9; error('change dz !'); end

layer = [];
layer = f_add_layer(layer,'id_layer','LLoair','thickness',hAir,'nb_slice',6,'z_type','log-1.5');
layer = f_add_layer(layer,'id_layer','LIout1','thickness',hIndOut,'nb_slice',6,'z_type','log-1.5');
allLmove = [];
for i = 1:nbdz
    idmove = ['L' num2str(i)];
    allLmove{i} = idmove;
    layer = f_add_layer(layer,'id_layer',idmove,'thickness',dz,'nb_slice',5,'z_type','lin');
end
layer = f_add_layer(layer,'id_layer','LIout2','thickness',hIndOut,'nb_slice',6,'z_type','log+1.5');
layer = f_add_layer(layer,'id_layer','LHiair','thickness',hAir,'nb_slice',6,'z_type','log+1.5');

%% Make mesh 3D

% dom3d = f_make_mesh_3d('mesher','hexa2dto3d','dom2d',dom2d,'layer',layer);
design3d = [];
design3d = f_add_mesh_3d(design3d,'id_mesh','mesh1','mesher','hexa2dto3d','dom2d',dom2d,'layer',layer);

% dom3dx = dom3d.mesh.node(1,:);
% dom3dy = dom3d.mesh.node(2,:);
% dom3dz = dom3d.mesh.node(3,:);
% dom3d.mesh.node(2,:) = dom3dz;
% dom3d.mesh.node(3,:) = dom3dy;
% dom3dcx = dom3d.mesh.cnode(1,:);
% dom3dcy = dom3d.mesh.cnode(2,:);
% dom3dcz = dom3d.mesh.cnode(3,:);
% dom3d.mesh.cnode(2,:) = dom3dcz;
% dom3d.mesh.cnode(3,:) = dom3dcy;

%% 

%         Define 3D regions
%         ID identification of 2D regions + IDLayer (user defined !)


%--------------------------------------------------------------------------

design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','ZH',...
                            'id_dom2d',[1000],...
                            'id_layer',allLmove);
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','LSP',...
                            'id_dom2d',[4],...
                            'id_layer',allLmove);
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','INS',...
                            'id_dom2d',[3],...
                            'id_layer',allLmove);
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','E60',...
                            'id_dom2d',[2],...
                            'id_layer',allLmove);

% -------------------------------
IndPosition = 2*dz;
IndY0 = hAir + hIndOut + IndPosition;
nbLI0 = IndPosition/dz;
if abs(mod(nbLI0,1)) > 1e-9; error('change IndPosition !'); end

id_dom2d_Ind{1} = [6, 7]; % Ix1 Ix5
id_layer_Ind{1} = ['L' num2str(nbLI0)];
id_dom2d_Ind{2} = [6]; % Ix1
id_layer_Ind{2} = {['L' num2str(nbLI0+1)], ['L' num2str(nbLI0+2)], ['L' num2str(nbLI0+3)]};
id_dom2d_Ind{3} = [6, 7]; % Ix1 Ix5
id_layer_Ind{3} = ['L' num2str(nbLI0+4)];

nbszInd = length(id_layer_Ind);
centerInd = IndY0 + nbszInd/2 * dz;
centerIndy = IndY0 + nbszInd/2 * dz;
centerIndx = IndY0 + nbszInd/2 * dz;

design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','INDUCTOR',...
                                'id_dom2d',id_dom2d_Ind,...
                                'id_layer',id_layer_Ind);


%% 

%         ID identification of 2D regions + IDLayer (user defined !)


%--------------------------------------------------------------------------

sigCoil = 10e6;
sigLSP  = 0.2e6;
murLSP  = 1;
Icoil   = 1000;
fr      = 200e3;
%--------------------------------------------------------------------------
sigmaZ = f_make_parameter('f',20e4);
tsigZ = f_make_gtensor('type','isotropic','value',sigmaZ);
%--------------------------------------------------------------------------
design3d = f_add_econductor(design3d,'id_dom3d','ZH','sigma',tsigZ);
design3d = f_add_coil(design3d,'id_dom3d','INDUCTOR',...
                         'coil_type','stranded',...
                         'coil_mode','transmitter',...
                         'etrode_type','open',...
                         'petrode_equation',{['y > max(y)-1e-9 & z < ' num2str(centerInd)]},...
                         'netrode_equation',{['y > max(y)-1e-9 & z > ' num2str(centerInd)]},...
                         'stype','j','i_coil',Icoil,...
                         'cs_area',xi * eind,...
                         'nb_turn',1, ...
                         'id_bcon',1);
%--------------------------------------------------------------------------
design3d = f_add_bcon(design3d,'defined_on','edge','id_elem',':',...
                         'bc_type','fixed','bc_value',0);

%% Test 03
figure
f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,design3d.econductor(1).id_elem),...
             'elem_type','hex','color',f_randcolor); hold on
f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,design3d.coil(1).id_elem),...
             'elem_type','hex','color','non'); hold on
f_viewthings('type','node','node',design3d.mesh.node(:,design3d.coil(1).petrode(1).id_node),'color','y');
f_viewthings('type','node','node',design3d.mesh.node(:,design3d.coil(1).netrode(1).id_node),'color','gr');
axis equal




%% ---- Eddy-current ----
design3d = f_make_system(design3d,'formulation','APhi','fr',fr,...
                            'id_bcon_A',[1]);
design3d = f_solve_system(design3d,'formulation','APhi');
ZCoil = design3d.APhi.ZCoil(1);

%%
figure
IDElem = design3d.econductor(1).id_elem;
f_quiver(design3d.mesh.cnode(:,IDElem),imag(design3d.APhi.J(:,IDElem)),'sfactor',1,'vtype','equal');
figure
IDElem = design3d.econductor(1).id_elem;
f_quiver(design3d.mesh.cnode(:,IDElem),real(design3d.APhi.J(:,IDElem)),'sfactor',1,'vtype','equal');

%%
figure
IDElem = design3d.econductor(1).id_elem;
f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,IDElem),...
             'elem_type',design3d.mesh.elem_type,'field',design3d.APhi.pV(:,IDElem));
fprintf('Total power : %f \n', sum(design3d.mesh.v_elem(IDElem) .* design3d.APhi.pV(IDElem)))


%%
figure
f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,design3d.coil(1).id_elem),...
             'elem_type','hex','color','non'); hold on
IDElem = design3d.coil(1).id_elem;
f_quiver(design3d.mesh.cnode(:,IDElem),design3d.coil(1).N(:,IDElem),'sfactor',1);
axis equal








