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
msize = 2;

c3dobj = [];
c3dobj = f_add_x(c3dobj,'id_x','xair_a','d',lPlate,'dnum',msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xplate_a','d',lPlate/2 - lCoil/2,'dnum',5*msize,'dtype','log-');
c3dobj = f_add_x(c3dobj,'id_x','xcoil','d',lCoil,'dnum',msize,'dtype','log+-');
c3dobj = f_add_x(c3dobj,'id_x','xplate_b','d',lPlate/2 - lCoil/2,'dnum',5*msize,'dtype','log+');
c3dobj = f_add_x(c3dobj,'id_x','xair_b','d',lPlate,'dnum',msize,'dtype','log+');

c3dobj = f_add_y(c3dobj,'id_y','yair_a','d',lPlate,'dnum',msize,'dtype','log-');
c3dobj = f_add_y(c3dobj,'id_y','yplate_a','d',hPlate-esurf,'dnum',2*msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','yplate_esurf','d',esurf,'dnum',1,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','yagap','d',agap,'dnum',msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','ycoil','d',hCoil,'dnum',msize,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','yair_b','d',lPlate,'dnum',2*msize,'dtype','log+');

c3dobj = f_add_layer(c3dobj,'id_layer','layer_a','d',lPlate,'dnum',5,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','lLine','d',1e-6,'dnum',1,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','layer_b','d',lPlate,'dnum',5,'dtype','lin');


c3dobj = f_add_mesh2d(c3dobj,'id_mesh2d','mesh2d_light','build_from','mesh1d',...
        'id_x', {'xair_a','xplate_a','xcoil','xplate_b','xair_b'},...
        'id_y', {'yair_a','yplate_a','yplate_esurf','yagap','ycoil','yair_b'});

c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_light',...
        'id_dom2d','plate2d', ...
        'id_x', {'xplate_a','xcoil','xplate_b'},...
        'id_y', {'yplate_a','yplate_esurf'});
c3dobj = f_add_dom2d(c3dobj,'id_mesh2d','mesh2d_light',...
        'id_dom2d','lcorner', ...
        'elem_code', 26.419095566573130);

c3dobj = f_add_dom2d(c3dobj,'id_dom2d','coil2d','id_x','xcoil','id_y',{'ycoil'});
c3dobj = f_add_dom2d(c3dobj,'id_dom2d','esurf2d','id_x',{'xplate...','xcoil'},'id_y','yplate_esurf');

figure
f_view_mesh2d(c3dobj,'color','w'); hold on
f_view_mesh2d(c3dobj,'id_dom2d','plate2d','color',f_color(1));
f_view_mesh2d(c3dobj,'id_dom2d','coil2d','color',f_color(2));
f_view_mesh2d(c3dobj,'id_dom2d','esurf2d','color',f_color(3));
f_view_mesh2d(c3dobj,'id_dom2d','lcorner','color',f_color(4));


c3dobj = f_add_mesh3d(c3dobj,'id_mesh3d','mesh1','mesher','c3d_hexamesh',...
                       'id_mesh2d',{'mesh2d_light'},...
                       'id_mesh1d',[],...
                       'id_layer',{'layer_a','lLine','layer_b'});

c3dobj = f_add_dom3d(c3dobj,'id_dom3d','coil', 'id_mesh3d','mesh1', ...
                      'id_dom2d','coil2d','id_layer',{'layer_a','lLine','layer_b'});
                  
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','plate', ...
                      'id_dom2d',{'plate2d','esurf2d'},'id_layer',{'layer_...','lLine'});


% figure
% f_view_mesh3d(geo,'id_mesh3d','mesh1','id_dom3d','plate','color',f_color(5));


c3dobj = f_add_emdesign3d(c3dobj,'id_emdesign3d','Inf_coil_over_plate','id_mesh3d','mesh1');

c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','Inf_coil_over_plate',...
                          'id_econductor','plate', ...
                          'id_dom3d','plate','sigma',tsigPlate);
c3dobj = f_add_econductor(c3dobj,'id_emdesign3d','Inf_coil_over_plate',...
                          'id_econductor','coil', ...
                          'id_dom3d','coil','sigma',tsigCoil);
                      
c3dobj = f_add_open_jscoil(c3dobj,'id_emdesign3d','Inf_coil_over_plate',...
                            'id_dom3d','coil',...
                            'id_coil','js_coil',...
                            'coil_mode','transmitter',...
                            'petrode_equation',{['z > max(z)-1e-9']},...
                            'netrode_equation',{['z < min(z)+1e-9']},...
                            'j_coil',1e6);

%
% node = c3dobj.mesh3d.mesh1.node;
% elem = c3dobj.mesh3d.mesh1.elem;
% geo = c3dobj.emdesign3d.Inf_coil_over_plate.coil.js_coil.petrode;
% IDElem = geo.id_elem;
% figure
% f_viewthings('type','elem','node',node,'elem',elem(:,:),...
%              'elem_type','hex','color','none','edge_color','k'); hold on;
% f_viewthings('type','elem','node',node,'elem',elem(:,IDElem),...
%              'elem_type','hex','color',f_color(1)); hold on;
% f_viewthings('type','node','node',node(:,geo.id_node),'color',f_color(2)); hold on;
% axis equal; axis tight; hold on
%


return
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
c3dobj = f_add_bcon(c3dobj,'defined_on','edge','id_elem',':',...
                         'bc_type','fixed','bc_value',0);
% (2)
c3dobj = f_add_bcon(c3dobj,'defined_on','face','id_dom3d','coil',...
                         'bc_type','sibc','sigma',sigCoil,'mur',1);


%% Solve EM


c3dobj.aphi.fr            = fr;
c3dobj.aphi.id_bcon_for_a = [1];
c3dobj.aphi.id_bcon_sibc  = [2];
%---
c3dobj.aphi.id_node_phi    = [];
c3dobj.aphi.id_edge_a      = 1:c3dobj.mesh.nbEdge;
c3dobj.aphi.id_elem_nomesh = [];
c3dobj.aphi.MVP            = [];
c3dobj.aphi.Phi            = [];

%%
%      SOLVE ELECTROMAG
c3dobj = f_build_sfield_aphi(c3dobj);
c3dobj = f_build_econ_aphi(c3dobj);
c3dobj = f_build_mcon_aphi(c3dobj);
c3dobj = f_build_air_aphi(c3dobj);
c3dobj = f_build_coil_aphi(c3dobj);
c3dobj = f_build_bcon_aphi(c3dobj);
c3dobj = f_build_nomesh_aphi(c3dobj);

figure
f_viewthings('node',c3dobj.mesh.node,...
             'edge',c3dobj.mesh.edge(1:2,c3dobj.aphi.id_edge_a),...
             'type','edge');
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%---------------------- Matrix system -------------------------------------

%--------------------------------------------------------------------------
%
%--------------------------- for dymamic case -----------------------------
K11 = c3dobj.mesh.R.' * ...
     (c3dobj.aphi.SWfnuWf + c3dobj.aphi.SWfWfAir) * ...
      c3dobj.mesh.R;
K11 = K11 + (1j*2*pi*c3dobj.aphi.fr) .* c3dobj.aphi.SWeWe;
K12 = (1j*2*pi*c3dobj.aphi.fr) .* (c3dobj.aphi.SWeWe * c3dobj.mesh.G);
K22 = (1j*2*pi*c3dobj.aphi.fr) .* (c3dobj.mesh.G.' * c3dobj.aphi.SWeWe * c3dobj.mesh.G);

% dirichlet remove
K11 = K11(c3dobj.aphi.id_edge_a,c3dobj.aphi.id_edge_a);
K12 = K12(c3dobj.aphi.id_edge_a,:);
K12 = K12(:,c3dobj.aphi.id_node_phi);
K22 = K22(c3dobj.aphi.id_node_phi,c3dobj.aphi.id_node_phi);
%---------------------- Global Matrix ---------------------------------
S = K11; clear K11;
S = [S K12];
S = [S; K12.' K22]; clear K12 K22;
RHS = c3dobj.aphi.coilRHS + c3dobj.aphi.fixedRHS + c3dobj.aphi.sfieldRHS;
RHS = RHS(c3dobj.aphi.id_edge_a,1);
RHS = [RHS; zeros(length(c3dobj.aphi.id_node_phi),1)];
if isfield(c3dobj,'coil')
    nb_coil = length(c3dobj.coil);
    for i = 1:nb_coil
        if strcmpi(c3dobj.coil(i).coil_model,'t3') && ...
           strcmpi(c3dobj.coil(i).coil_mode,'transmitter')
            if any(c3dobj.aphi.Alpha{i})
                K13 = (1j*2*pi*c3dobj.aphi.fr)*(c3dobj.aphi.SWeWe*c3dobj.mesh.G*c3dobj.aphi.Alpha{i});
                K23 = (1j*2*pi*c3dobj.aphi.fr)*(c3dobj.mesh.G.'*c3dobj.aphi.SWeWe*c3dobj.mesh.G*c3dobj.aphi.Alpha{i});
                K33 = (1j*2*pi*c3dobj.aphi.fr)*(c3dobj.aphi.Alpha{i}.'*c3dobj.mesh.G.'*c3dobj.aphi.SWeWe*c3dobj.mesh.G*c3dobj.aphi.Alpha{i});
                K13 = K13(c3dobj.aphi.id_edge_a,:);
                K23 = K23(c3dobj.aphi.id_node_phi,1);
                S   = [S [K13;  K23]];
                S   = [S; K13.' K23.' K33]; clear K13 K23 K33;
                RHS = [RHS; c3dobj.coil(i).i_coil];
            end
        end
        if strcmpi(c3dobj.coil(i).coil_model,'t4') && ...
           strcmpi(c3dobj.coil(i).coil_mode,'transmitter')
            if any(c3dobj.aphi.Alpha{i})
                v_etrode = c3dobj.coil(i).v_petrode - c3dobj.coil(i).v_netrode;
                vRHSed = - c3dobj.aphi.SWeWe  * ...
                           c3dobj.mesh.G * (c3dobj.aphi.Alpha{i} .* v_etrode);
                vRHSed = vRHSed(c3dobj.aphi.id_edge_a);
                vRHSno = - c3dobj.mesh.G.'  * c3dobj.aphi.SWeWe * c3dobj.mesh.G * ...
                          (c3dobj.aphi.Alpha{i} .* v_etrode);
                vRHSno = vRHSno(c3dobj.aphi.id_node_phi);
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
c3dobj.aphi.flag = flag;
c3dobj.aphi.relres = relres;
c3dobj.aphi.iter = iter;
c3dobj.aphi.resvec = resvec;
c3dobj.aphi.residual = resvec/norm(RHS);


%--------------------------------------------------------------------------
% --- Circulation of Magnetic Vector Potential (MVP)
c3dobj.aphi.MVP = zeros(c3dobj.mesh.nbEdge,1);
c3dobj.aphi.MVP(c3dobj.aphi.id_edge_a) = ...
              MVPPhi(1:length(c3dobj.aphi.id_edge_a));
%----------------------------------------------------------------------
% --- Phi
Phi = zeros(c3dobj.mesh.nbNode,1);
if length(MVPPhi) > length(c3dobj.aphi.id_edge_a)
    Phi(c3dobj.aphi.id_node_phi) = ...
              MVPPhi(length(c3dobj.aphi.id_edge_a)+1:...
                     length(c3dobj.aphi.id_edge_a)+...
                     length(c3dobj.aphi.id_node_phi));
end
if isfield(c3dobj,'coil') % --- add phi static in massive coils
    nb_dom = length(c3dobj.coil);
    c3dobj.aphi.ICoil = zeros(1,nb_dom);
    for i = 1:nb_dom
        switch [c3dobj.coil(i).coil_model c3dobj.coil(i).coil_mode]
            case 't3transmitter'
                if length(MVPPhi) > length(c3dobj.aphi.id_edge_a)+length(c3dobj.aphi.id_node_phi)
                    dPhi = MVPPhi(length(c3dobj.aphi.id_edge_a)+length(c3dobj.aphi.id_node_phi)+1:end);
                    Voltage = 1j*2*pi*c3dobj.aphi.fr .* dPhi;
                    Phi = Phi + 1/(1j*2*pi*c3dobj.aphi.fr).*(c3dobj.aphi.Alpha{i} .* Voltage);
                end
            case 't4transmitter'
                Voltage = c3dobj.coil(i).v_petrode - c3dobj.coil(i).v_netrode;
                Phi = Phi + 1/(1j*2*pi*c3dobj.aphi.fr).*(c3dobj.aphi.Alpha{i} .* Voltage);
        end
    end
end

%%
c3dobj.aphi.Phi = Phi;
c3dobj.aphi.V = 1j*2*pi*c3dobj.aphi.fr .* c3dobj.aphi.Phi;
%--------------------------------------------------------------------------
% --- Flux ----------------------------------------------------------------
c3dobj.aphi.Flux = c3dobj.mesh.R * c3dobj.aphi.MVP;
% --- Electromotive Force (EMF) -------------------------------------------
c3dobj.aphi.EMF = -(1j*2*pi*c3dobj.aphi.fr).* ...
    (c3dobj.aphi.MVP + c3dobj.mesh.G * c3dobj.aphi.Phi);
%--------------------------------------------------------------------------
c3dobj.aphi.B = f_postpro3d(c3dobj.mesh,c3dobj.aphi.Flux,'W2');



%% Compute J, P

if isfield(c3dobj,'econductor')
    c3dobj.aphi.J  = zeros(3,c3dobj.mesh.nbElem);
    c3dobj.aphi.pV = zeros(1,c3dobj.mesh.nbElem);
    c3dobj.aphi.PVT = 0;
    nb_dom = length(c3dobj.econductor);
    for i = 1:nb_dom
        J = f_postpro3d(c3dobj.mesh,c3dobj.aphi.EMF,'W1',...
            'id_elem',c3dobj.econductor(i).id_elem,...
            'coef',c3dobj.econductor(i).gtensor);
        gtinv = f_invtensor(c3dobj.econductor(i).gtensor);
        pV = f_torowv(gtinv(1,1,:)) .* conj(J(1,:)) .* J(1,:) + ...
             f_torowv(gtinv(1,2,:)) .* conj(J(1,:)) .* J(2,:) + ...
             f_torowv(gtinv(1,3,:)) .* conj(J(1,:)) .* J(3,:) + ...
             f_torowv(gtinv(2,1,:)) .* conj(J(2,:)) .* J(1,:) + ...
             f_torowv(gtinv(2,2,:)) .* conj(J(2,:)) .* J(2,:) + ...
             f_torowv(gtinv(2,3,:)) .* conj(J(2,:)) .* J(3,:) + ...
             f_torowv(gtinv(3,1,:)) .* conj(J(3,:)) .* J(1,:) + ...
             f_torowv(gtinv(3,2,:)) .* conj(J(3,:)) .* J(2,:) + ...
             f_torowv(gtinv(3,3,:)) .* conj(J(3,:)) .* J(3,:);
        c3dobj.aphi.J(1:3,c3dobj.econductor(i).id_elem) = J;
        c3dobj.aphi.pV(1,c3dobj.econductor(i).id_elem)  = 1/2.*real(pV);
    end
    c3dobj.aphi.PVT = sum(c3dobj.aphi.pV .* c3dobj.mesh.v_elem);
end
if isfield(c3dobj,'bcon')
    c3dobj.aphi.Js = zeros(2,c3dobj.mesh.nbFace);
    c3dobj.aphi.pS = zeros(1,c3dobj.mesh.nbFace);
    nb_bcon = length(c3dobj.bcon);
    for i = 1:nb_bcon
        if strcmpi(c3dobj.bcon(i).bc_type,'sibc')
            Js = f_postpro3d(c3dobj.mesh,c3dobj.aphi.EMF,'W1_onFace',...
                'id_face',c3dobj.bcon(i).id_face,...
                'coef',c3dobj.bcon(i).gtsigma);
            mu0 = 4*pi*1e-7;
            sig = det(c3dobj.bcon(i).gtsigma)^(1/3);
            mu  = mu0 *  det(c3dobj.bcon(i).gtmur)^(1/3);
            skindepth = sqrt(2/(2*pi*c3dobj.aphi.fr*mu*sig));
            gtinv = f_invtensor(c3dobj.bcon(i).gtsigma);
            pS = gtinv(1,1,:) .* conj(Js(1,:)) .* Js(1,:) + ...
                 gtinv(1,2,:) .* conj(Js(1,:)) .* Js(2,:) + ...
                 gtinv(2,1,:) .* conj(Js(2,:)) .* Js(1,:) + ...
                 gtinv(2,2,:) .* conj(Js(2,:)) .* Js(2,:);
            c3dobj.aphi.pS(:,c3dobj.bcon(i).id_face) = real(pS).*skindepth/2;
            c3dobj.aphi.Js(:,c3dobj.bcon(i).id_face) = Js;
        end
    end
    c3dobj.aphi.PST = sum(c3dobj.aphi.pS .* c3dobj.mesh.a_face);
end

%--------------------------------------------------------------------------
% --- coil : ZCoil, L0Coil, ICoil, VCoil
if isfield(c3dobj,'coil')
    nb_dom = length(c3dobj.coil);
    c3dobj.aphi.ICoil = zeros(1,nb_dom);
    for idom = 1:nb_dom
        switch [c3dobj.coil(idom).coil_model c3dobj.coil(idom).coil_mode]
            case 't3transmitter'
                c3dobj.aphi.ICoil(idom) = -((c3dobj.aphi.SWeWe * c3dobj.aphi.EMF).')*(c3dobj.mesh.G * c3dobj.aphi.Alpha{idom});
                c3dobj.aphi.VCoil(idom) = mean(c3dobj.aphi.V(c3dobj.coil(idom).petrode(1).id_node)) - ...
                                            mean(c3dobj.aphi.V(c3dobj.coil(idom).netrode(1).id_node));
                c3dobj.aphi.ZCoil(idom) = c3dobj.aphi.VCoil(idom)/c3dobj.aphi.ICoil(idom);
            case 't4transmitter'
                c3dobj.aphi.ICoil(idom) = -((c3dobj.aphi.SWeWe * c3dobj.aphi.EMF).')*(c3dobj.mesh.G * c3dobj.aphi.Alpha{idom});
                c3dobj.aphi.VCoil(idom) = c3dobj.coil(idom).v_petrode - c3dobj.coil(idom).v_netrode;
                c3dobj.aphi.ZCoil(idom) = c3dobj.aphi.VCoil(idom)/c3dobj.aphi.ICoil(idom);
        end
    end
end
c3dobj.aphi.SWeWe = [];


%% Plotting

% ---

IDElem = [c3dobj.dom3d.('esurf').id_elem];
xnode  = c3dobj.mesh.cnode(1,IDElem);
[xnode, ixnode] = sort(xnode);

xnode = xnode - mean(xnode);

figure
subplot(121)
plot(xnode,-(imag(c3dobj.aphi.J(3,IDElem(ixnode)))),'b');
title('imag J');
subplot(122)
plot(xnode,-(real(c3dobj.aphi.J(3,IDElem(ixnode)))),'b');
title('real J');

figure
subplot(121)
f_quiver(c3dobj.mesh.cnode(:,IDElem),imag(c3dobj.aphi.J(:,IDElem)),'sfactor',1);
title('imag J');
subplot(122)
f_quiver(c3dobj.mesh.cnode(:,IDElem),real(c3dobj.aphi.J(:,IDElem)),'sfactor',1);
title('real J');




% ---
figure
IDElem = c3dobj.bcon(2).id_face;
f_viewthings('type','face','node',c3dobj.mesh.node,'face',c3dobj.mesh.face(:,IDElem),...
             'field',f_norm(abs(c3dobj.aphi.Js(:,IDElem))).');
title('|J|Inductor')

% ---





