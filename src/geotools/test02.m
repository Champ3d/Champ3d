clear
close all
clc

%% main parameters
lPlate   = 100e-3;
hPlate   = 3e-3;
sigPlate = 40e3;
murPlate = 1;
lCoil    = 10e-3;
hCoil    = 5e-3;
sigCoil  = 58e6;
agap     = 2e-3;
esurf    = 1e-4; 
abox     = lPlate * 2;
Imax     = 1000;
nb_turns = 1;
fr       = 200e3;
Iphase   = 'IA'; 
Isign    = +1;

tsigCoil  = f_make_gtensor('type','isotropic','value',sigCoil);

tsigPlate = f_make_gtensor('type','gtensor',...
    'main_value',sigPlate,'ort1_value',sigPlate,'ort2_value',sigPlate,...
    'main_dir',[0 0 1],'ort1_dir',[1 0 0],'ort2_dir',[0 1 0]);

%% 2D mesh
msize = 5;

geo = [];
geo = f_add_x(geo,'id_x','xair_a','d',lPlate,'dnum',msize,'dtype','log-');
geo = f_add_x(geo,'id_x','xplate_a','d',lPlate/2 - lCoil/2,'dnum',5*msize,'dtype','log-');
geo = f_add_x(geo,'id_x','xcoil','d',lCoil,'dnum',2*msize,'dtype','lin');
geo = f_add_x(geo,'id_x','xplate_b','d',lPlate/2 - lCoil/2,'dnum',5*msize,'dtype','log+');
geo = f_add_x(geo,'id_x','xair_b','d',lPlate,'dnum',msize,'dtype','log+');

geo = f_add_y(geo,'id_y','yair_a','d',lPlate,'dnum',msize,'dtype','log-');
geo = f_add_y(geo,'id_y','yplate_a','d',hPlate-esurf,'dnum',2*msize,'dtype','lin');
geo = f_add_y(geo,'id_y','yplate_esurf','d',esurf,'dnum',1,'dtype','lin');
geo = f_add_y(geo,'id_y','yagap','d',agap,'dnum',msize,'dtype','lin');
geo = f_add_y(geo,'id_y','ycoil','d',hCoil,'dnum',msize,'dtype','lin');
geo = f_add_y(geo,'id_y','yair_b','d',lPlate,'dnum',2*msize,'dtype','log+');

geo = f_add_layer(geo,'id_layer','layer_a','d',lPlate,'dnum',5,'dtype','lin');
geo = f_add_layer(geo,'id_layer','lLine','d',1e-6,'dnum',1,'dtype','lin');
geo = f_add_layer(geo,'id_layer','layer_b','d',lPlate,'dnum',5,'dtype','lin');


geo = f_add_mesh2d(geo,'id_mesh2d','mesh2d_light','build_from','geo1d',...
        'id_x', {'xair_a','xplate_a','xcoil','xplate_b','xair_b'},...
        'id_y', {'yair_a','yplate_a','yplate_esurf','yagap','ycoil','yair_b'});

geo = f_add_dom2d(geo,'id_mesh2d','mesh2d_light',...
        'id_dom2d','plate2d', ...
        'id_x', {'xplate_a','xcoil','xplate_b'},...
        'id_y', {'yplate_a','yplate_esurf'});


figure
f_view_mesh2d(geo,'color',f_color(10)); hold on
f_view_mesh2d(geo,'id_dom2d','plate2d','color',f_color(2));


return


%% Make mesh 3D

design3d = [];
design3d = f_add_mesh_3d(design3d,'id_mesh','mesh1','mesher','hexa2dto3d',...
                           'dom2d',dom2d,'layer',layer);

fprintf('Define 3D regions ... \n');
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','plate',...
                            'id_dom2d',[id_dom2d_plate id_dom2d_esurf],...
                            'id_layer',{'allLayer1','lLine','allLayer2'});
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','esurf',...
                            'id_dom2d',id_dom2d_esurf,...
                            'id_layer',{'lLine'});
design3d = f_add_dom3d(design3d,'defined_on','elem','id_dom3d','coil',...
                            'id_dom2d',id_dom2d_coil,...
                            'id_layer',{'allLayer1','lLine','allLayer2'});
% % ---
% figure
% IDElem = design3d.dom3d.plate.id_elem;
% f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,IDElem),...
%              'elem_type','hex','color',f_randcolor); hold on;
% title('plate');
% axis equal; axis tight; hold on
% %---
% IDElem = design3d.dom3d.coil.id_elem;
% f_viewthings('type','elem','node',design3d.mesh.node,'elem',design3d.mesh.elem(:,IDElem),...
%              'elem_type','hex','color',f_randcolor); hold on;
% title('coil');
% axis equal; axis tight; hold on
% 
% %---
% figure
% f_view_meshquad(p2d,t2d,i_elem_2d_coil,f_randcolor); hold on
% f_view_meshquad(p2d,t2d,i_elem_2d_plate,f_randcolor); hold on


%% Define physical domains

design3d = f_add_econductor(design3d,'id_dom3d','plate','sigma',tsigPlate);

design3d = f_add_coil(design3d,'id_dom3d','coil',...
                         'coil_type','massive',...
                         'coil_mode','transmitter',...
                         'etrode_type','open',...
                         'petrode_equation',{['z > max(z)-1e-9']},...
                         'netrode_equation',{['z < min(z)+1e-9']},...
                         'i_coil',Imax,...
                         'stype','i',...
                         'id_bcon',1);
                     
design3d = f_add_nomesh(design3d,'id_dom3d','coil');

% figure
% f_viewthings('node',design3d.mesh.node,...
%              'edge',design3d.mesh.edge(1:2,design3d.nomesh.id_inside_edge),...
%              'type','edge');
% figure
% f_viewthings('node',design3d.mesh.node,...
%              'edge',design3d.mesh.edge(1:2,design3d.nomesh.id_edge),...
%              'type','edge');
%% BC
% (1)
design3d = f_add_bcon(design3d,'defined_on','edge','id_elem',':',...
                         'bc_type','fixed','bc_value',0);
% (2)
design3d = f_add_bcon(design3d,'defined_on','face','id_dom3d','coil',...
                         'bc_type','sibc','sigma',sigCoil,'mur',1);


%% Solve EM


design3d.aphi.fr            = fr;
design3d.aphi.id_bcon_for_a = [1];
design3d.aphi.id_bcon_sibc  = [2];
%---
design3d.aphi.id_node_phi    = [];
design3d.aphi.id_edge_a      = 1:design3d.mesh.nbEdge;
design3d.aphi.id_elem_nomesh = [];
design3d.aphi.MVP            = [];
design3d.aphi.Phi            = [];

%%
%      SOLVE ELECTROMAG
design3d = f_build_sfield_aphi(design3d);
design3d = f_build_econ_aphi(design3d);
design3d = f_build_mcon_aphi(design3d);
design3d = f_build_air_aphi(design3d);
design3d = f_build_coil_aphi(design3d);
design3d = f_build_bcon_aphi(design3d);
design3d = f_build_nomesh_aphi(design3d);

figure
f_viewthings('node',design3d.mesh.node,...
             'edge',design3d.mesh.edge(1:2,design3d.aphi.id_edge_a),...
             'type','edge');
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%---------------------- Matrix system -------------------------------------

%--------------------------------------------------------------------------
%
%--------------------------- for dymamic case -----------------------------
K11 = design3d.mesh.R.' * ...
     (design3d.aphi.SWfnuWf + design3d.aphi.SWfWfAir) * ...
      design3d.mesh.R;
K11 = K11 + (1j*2*pi*design3d.aphi.fr) .* design3d.aphi.SWeWe;
K12 = (1j*2*pi*design3d.aphi.fr) .* (design3d.aphi.SWeWe * design3d.mesh.G);
K22 = (1j*2*pi*design3d.aphi.fr) .* (design3d.mesh.G.' * design3d.aphi.SWeWe * design3d.mesh.G);

% dirichlet remove
K11 = K11(design3d.aphi.id_edge_a,design3d.aphi.id_edge_a);
K12 = K12(design3d.aphi.id_edge_a,:);
K12 = K12(:,design3d.aphi.id_node_phi);
K22 = K22(design3d.aphi.id_node_phi,design3d.aphi.id_node_phi);
%---------------------- Global Matrix ---------------------------------
S = K11; clear K11;
S = [S K12];
S = [S; K12.' K22]; clear K12 K22;
RHS = design3d.aphi.coilRHS + design3d.aphi.fixedRHS + design3d.aphi.sfieldRHS;
RHS = RHS(design3d.aphi.id_edge_a,1);
RHS = [RHS; zeros(length(design3d.aphi.id_node_phi),1)];
if isfield(design3d,'coil')
    nb_coil = length(design3d.coil);
    for i = 1:nb_coil
        if strcmpi(design3d.coil(i).coil_model,'t3') && ...
           strcmpi(design3d.coil(i).coil_mode,'transmitter')
            if any(design3d.aphi.Alpha{i})
                K13 = (1j*2*pi*design3d.aphi.fr)*(design3d.aphi.SWeWe*design3d.mesh.G*design3d.aphi.Alpha{i});
                K23 = (1j*2*pi*design3d.aphi.fr)*(design3d.mesh.G.'*design3d.aphi.SWeWe*design3d.mesh.G*design3d.aphi.Alpha{i});
                K33 = (1j*2*pi*design3d.aphi.fr)*(design3d.aphi.Alpha{i}.'*design3d.mesh.G.'*design3d.aphi.SWeWe*design3d.mesh.G*design3d.aphi.Alpha{i});
                K13 = K13(design3d.aphi.id_edge_a,:);
                K23 = K23(design3d.aphi.id_node_phi,1);
                S   = [S [K13;  K23]];
                S   = [S; K13.' K23.' K33]; clear K13 K23 K33;
                RHS = [RHS; design3d.coil(i).i_coil];
            end
        end
        if strcmpi(design3d.coil(i).coil_model,'t4') && ...
           strcmpi(design3d.coil(i).coil_mode,'transmitter')
            if any(design3d.aphi.Alpha{i})
                v_etrode = design3d.coil(i).v_petrode - design3d.coil(i).v_netrode;
                vRHSed = - design3d.aphi.SWeWe  * ...
                           design3d.mesh.G * (design3d.aphi.Alpha{i} .* v_etrode);
                vRHSed = vRHSed(design3d.aphi.id_edge_a);
                vRHSno = - design3d.mesh.G.'  * design3d.aphi.SWeWe * design3d.mesh.G * ...
                          (design3d.aphi.Alpha{i} .* v_etrode);
                vRHSno = vRHSno(design3d.aphi.id_node_phi);
                RHS = RHS + [vRHSed; vRHSno];
            end
        end
    end
end

fprintf('%.4f s \n',toc);
%--------------------------------------------------------------------------
if any(diag(S)==0)
    error([mfilename ' : zeros on the diagonal of system matrix --> check mesh and problem definition !']);
end
%--------------------------------------------------------------------------


fprintf('Solving system ... ');
tic
precon = sqrt(diag(diag(S)));
[MVPPhi,flag,relres,iter,resvec] = qmr(S,RHS,1e-7,4000,precon.',precon);
clear precon S
fprintf('%.4f s \n',toc);
%--
design3d.aphi.flag = flag;
design3d.aphi.relres = relres;
design3d.aphi.iter = iter;
design3d.aphi.resvec = resvec;
design3d.aphi.residual = resvec/norm(RHS);


%--------------------------------------------------------------------------
% --- Circulation of Magnetic Vector Potential (MVP)
design3d.aphi.MVP = zeros(design3d.mesh.nbEdge,1);
design3d.aphi.MVP(design3d.aphi.id_edge_a) = ...
              MVPPhi(1:length(design3d.aphi.id_edge_a));
%----------------------------------------------------------------------
% --- Phi
Phi = zeros(design3d.mesh.nbNode,1);
if length(MVPPhi) > length(design3d.aphi.id_edge_a)
    Phi(design3d.aphi.id_node_phi) = ...
              MVPPhi(length(design3d.aphi.id_edge_a)+1:...
                     length(design3d.aphi.id_edge_a)+...
                     length(design3d.aphi.id_node_phi));
end
if isfield(design3d,'coil') % --- add phi static in massive coils
    nb_dom = length(design3d.coil);
    design3d.aphi.ICoil = zeros(1,nb_dom);
    for i = 1:nb_dom
        switch [design3d.coil(i).coil_model design3d.coil(i).coil_mode]
            case 't3transmitter'
                if length(MVPPhi) > length(design3d.aphi.id_edge_a)+length(design3d.aphi.id_node_phi)
                    dPhi = MVPPhi(length(design3d.aphi.id_edge_a)+length(design3d.aphi.id_node_phi)+1:end);
                    Voltage = 1j*2*pi*design3d.aphi.fr .* dPhi;
                    Phi = Phi + 1/(1j*2*pi*design3d.aphi.fr).*(design3d.aphi.Alpha{i} .* Voltage);
                end
            case 't4transmitter'
                Voltage = design3d.coil(i).v_petrode - design3d.coil(i).v_netrode;
                Phi = Phi + 1/(1j*2*pi*design3d.aphi.fr).*(design3d.aphi.Alpha{i} .* Voltage);
        end
    end
end

%%
design3d.aphi.Phi = Phi;
design3d.aphi.V = 1j*2*pi*design3d.aphi.fr .* design3d.aphi.Phi;
%--------------------------------------------------------------------------
% --- Flux ----------------------------------------------------------------
design3d.aphi.Flux = design3d.mesh.R * design3d.aphi.MVP;
% --- Electromotive Force (EMF) -------------------------------------------
design3d.aphi.EMF = -(1j*2*pi*design3d.aphi.fr).* ...
    (design3d.aphi.MVP + design3d.mesh.G * design3d.aphi.Phi);
%--------------------------------------------------------------------------
design3d.aphi.B = f_postpro3d(design3d.mesh,design3d.aphi.Flux,'W2');



%% Compute J, P

if isfield(design3d,'econductor')
    design3d.aphi.J  = zeros(3,design3d.mesh.nbElem);
    design3d.aphi.pV = zeros(1,design3d.mesh.nbElem);
    design3d.aphi.PVT = 0;
    nb_dom = length(design3d.econductor);
    for i = 1:nb_dom
        J = f_postpro3d(design3d.mesh,design3d.aphi.EMF,'W1',...
            'id_elem',design3d.econductor(i).id_elem,...
            'coef',design3d.econductor(i).gtensor);
        gtinv = f_invtensor(design3d.econductor(i).gtensor);
        pV = f_torowv(gtinv(1,1,:)) .* conj(J(1,:)) .* J(1,:) + ...
             f_torowv(gtinv(1,2,:)) .* conj(J(1,:)) .* J(2,:) + ...
             f_torowv(gtinv(1,3,:)) .* conj(J(1,:)) .* J(3,:) + ...
             f_torowv(gtinv(2,1,:)) .* conj(J(2,:)) .* J(1,:) + ...
             f_torowv(gtinv(2,2,:)) .* conj(J(2,:)) .* J(2,:) + ...
             f_torowv(gtinv(2,3,:)) .* conj(J(2,:)) .* J(3,:) + ...
             f_torowv(gtinv(3,1,:)) .* conj(J(3,:)) .* J(1,:) + ...
             f_torowv(gtinv(3,2,:)) .* conj(J(3,:)) .* J(2,:) + ...
             f_torowv(gtinv(3,3,:)) .* conj(J(3,:)) .* J(3,:);
        design3d.aphi.J(1:3,design3d.econductor(i).id_elem) = J;
        design3d.aphi.pV(1,design3d.econductor(i).id_elem)  = 1/2.*real(pV);
    end
    design3d.aphi.PVT = sum(design3d.aphi.pV .* design3d.mesh.v_elem);
end
if isfield(design3d,'bcon')
    design3d.aphi.Js = zeros(2,design3d.mesh.nbFace);
    design3d.aphi.pS = zeros(1,design3d.mesh.nbFace);
    nb_bcon = length(design3d.bcon);
    for i = 1:nb_bcon
        if strcmpi(design3d.bcon(i).bc_type,'sibc')
            Js = f_postpro3d(design3d.mesh,design3d.aphi.EMF,'W1_onFace',...
                'id_face',design3d.bcon(i).id_face,...
                'coef',design3d.bcon(i).gtsigma);
            mu0 = 4*pi*1e-7;
            sig = det(design3d.bcon(i).gtsigma)^(1/3);
            mu  = mu0 *  det(design3d.bcon(i).gtmur)^(1/3);
            skindepth = sqrt(2/(2*pi*design3d.aphi.fr*mu*sig));
            gtinv = f_invtensor(design3d.bcon(i).gtsigma);
            pS = gtinv(1,1,:) .* conj(Js(1,:)) .* Js(1,:) + ...
                 gtinv(1,2,:) .* conj(Js(1,:)) .* Js(2,:) + ...
                 gtinv(2,1,:) .* conj(Js(2,:)) .* Js(1,:) + ...
                 gtinv(2,2,:) .* conj(Js(2,:)) .* Js(2,:);
            design3d.aphi.pS(:,design3d.bcon(i).id_face) = real(pS).*skindepth/2;
            design3d.aphi.Js(:,design3d.bcon(i).id_face) = Js;
        end
    end
    design3d.aphi.PST = sum(design3d.aphi.pS .* design3d.mesh.a_face);
end

%--------------------------------------------------------------------------
% --- coil : ZCoil, L0Coil, ICoil, VCoil
if isfield(design3d,'coil')
    nb_dom = length(design3d.coil);
    design3d.aphi.ICoil = zeros(1,nb_dom);
    for idom = 1:nb_dom
        switch [design3d.coil(idom).coil_model design3d.coil(idom).coil_mode]
            case 't3transmitter'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
                design3d.aphi.VCoil(idom) = mean(design3d.aphi.V(design3d.coil(idom).petrode(1).id_node)) - ...
                                            mean(design3d.aphi.V(design3d.coil(idom).netrode(1).id_node));
                design3d.aphi.ZCoil(idom) = design3d.aphi.VCoil(idom)/design3d.aphi.ICoil(idom);
            case 't4transmitter'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
                design3d.aphi.VCoil(idom) = design3d.coil(idom).v_petrode - design3d.coil(idom).v_netrode;
                design3d.aphi.ZCoil(idom) = design3d.aphi.VCoil(idom)/design3d.aphi.ICoil(idom);
        end
    end
end
design3d.aphi.SWeWe = [];


%% Plotting

% ---

IDElem = [design3d.dom3d.('esurf').id_elem];
xnode  = design3d.mesh.cnode(1,IDElem);
[xnode, ixnode] = sort(xnode);

xnode = xnode - mean(xnode);

figure
subplot(121)
plot(xnode,-(imag(design3d.aphi.J(3,IDElem(ixnode)))),'b');
title('imag J');
subplot(122)
plot(xnode,-(real(design3d.aphi.J(3,IDElem(ixnode)))),'b');
title('real J');

figure
subplot(121)
f_quiver(design3d.mesh.cnode(:,IDElem),imag(design3d.aphi.J(:,IDElem)),'sfactor',1);
title('imag J');
subplot(122)
f_quiver(design3d.mesh.cnode(:,IDElem),real(design3d.aphi.J(:,IDElem)),'sfactor',1);
title('real J');




% ---
figure
IDElem = design3d.bcon(2).id_face;
f_viewthings('type','face','node',design3d.mesh.node,'face',design3d.mesh.face(:,IDElem),...
             'field',f_norm(abs(design3d.aphi.Js(:,IDElem))).');
title('|J|Inductor')

% ---





