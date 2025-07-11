
close all
clear all
clc

%% Geo parameters
xplate = 10;
yplate = 10;
zplate = 2;

% --- mesh-size
xmsize = 5;
ymsize = 5;
zmsize = 1;

%% mesh1d

m1d_01 = Mesh1d();

% --- x
m1d_01.add_line1d('id','xplate','len',xplate,'dnum',xmsize,'dtype','lin');
% --- y
m1d_01.add_line1d('id','yplate','len',yplate,'dnum',ymsize,'dtype','lin');
% --- z
m1d_01.add_line1d('id','zplate','len',zplate,'dnum',zmsize,'dtype','lin');

%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x

% --- dom2d
m2d_01.add_vdom('id','plate',...
    'id_xline','x...',...
    'id_yline','y...');

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplate');

% -- dom3d-surface
m3d_01.add_sdom('id','hsurface',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
m3d_01.add_sdom('id','up_surface_heat',...
                'defined_on','bound_face',...
                'id_dom3d','plate','condition','z = max(z)');
%% FEM3dTherm = Model thermic 3d by FEM

% Physical parameters
% in SI base unit
lambda = 20;
rho    = 1000;
cp     = 1000;
h      = 10;
ps     = 0;
pv     = 1e7;

% --- initialization
th_01 = FEM3dTherm('parent_mesh',m3d_01,'T0',20);

% --- add physical dom should be done by using add_... method
th_01.add_thconductor('id','plate','id_dom3d','plate','lambda',lambda);
th_01.add_thcapacitor('id','plate','id_dom3d','plate','rho',rho,'cp',cp);
% ---
th_01.add_convection('id','plate_surface','id_dom3d','hsurface','h',h);
% --- heat flux = power surface density (W/m^2)
th_01.add_ps('id','ps','id_dom3d','up_surface_heat','ps',ps);
% --- power volume density = volumic losses (W/m^3)
th_01.add_pv('id','pv','id_dom3d','plate','pv',pv);

% --- local time, /!\rule: 1 PhysicalModel <=> 1 local time
ltime_01 = LTime('t0',0,'t_end',1,'dnum',4);
th_01.add_ltime(ltime_01);
%% 
% ---
th_01.solve;
% ---
% figure
% for i = 1:th_01.ltime.it_max
%     th_01.ltime.it = i;
%     th_01.thconductor.plate.plotT; hold on
%     caxis('auto'); colorbar; view(3);
%     % ---
%     pause(0.2)
%     % ---
%     if i < th_01.ltime.it_max
%         children = get(gca, 'children');
%         delete(children);
%     end
% end

%% base 01b

% --- initialization
th_01b = FEM3dTherm('parent_mesh',m3d_01,'T0',20);

% --- add physical dom should be done by using add_... method
th_01b.add_thconductor('id','plate','id_dom3d','plate','lambda',lambda);
th_01b.add_thcapacitor('id','plate','id_dom3d','plate','rho',rho,'cp',cp);
% ---
th_01b.add_convection('id','plate_surface','id_dom3d','hsurface','h',h);
% --- heat flux = power surface density (W/m^2)
th_01b.add_ps('id','ps','id_dom3d','up_surface_heat','ps',ps);
% --- power volume density = volumic losses (W/m^3)
th_01b.add_pv('id','pv','id_dom3d','plate','pv',pv);

% --- local time, /!\rule: 1 PhysicalModel <=> 1 local time
ltime_01 = LTime('t0',0,'t_end',2,'dnum',5);
th_01b.add_ltime(ltime_01);

% ---
th_01b.solve;



%% base 02

% --- mesh-size
xmsize = 10;
ymsize = 10;
zmsize = 2;

%% mesh1d

m1d_02 = Mesh1d();

% --- x
m1d_02.add_line1d('id','xplate','len',xplate,'dnum',xmsize,'dtype','lin');
% --- y
m1d_02.add_line1d('id','yplate','len',yplate,'dnum',ymsize,'dtype','lin');
% --- z
m1d_02.add_line1d('id','zplate','len',zplate,'dnum',zmsize,'dtype','lin');
m1d_02.add_line1d('id','zexter','len',zplate,'dnum',zmsize,'dtype','lin');

%% mesh2d-quad
m2d_02 = QuadMeshFrom1d('parent_mesh',m1d_02, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x

% --- dom2d
m2d_02.add_vdom('id','plate',...
    'id_xline','x...',...
    'id_yline','y...');

%% mesh3d-hex
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_02,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
m3d_02.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplate');
m3d_02.add_vdom('id','alldom',...
                'id_dom2d','plate',...
                'id_zline',{'zplate','zexter'});

% -- dom3d-surface
m3d_02.add_sdom('id','hsurface',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
m3d_02.add_sdom('id','up_surface_heat',...
                'defined_on','bound_face',...
                'id_dom3d','plate','condition','z = max(z)');
m3d_02.add_sdom('id','hall',...
                'defined_on','bound_face',...
                'id_dom3d','alldom');
%% FEM3dTherm = Model thermic 3d by FEM

% Physical parameters
% in SI base unit
lambda = 20;
rho    = 1000;
cp     = 1000;
h      = 10;
ps     = 0;
pv     = 1e7;

% --- initialization
th_02 = FEM3dTherm('parent_mesh',m3d_02,'T0',20);

% --- add physical dom should be done by using add_... method
th_02.add_thconductor('id','plate','id_dom3d','alldom','lambda',lambda);
th_02.add_thcapacitor('id','plate','id_dom3d','alldom','rho',rho,'cp',cp);
% ---
th_02.add_convection('id','plate_surface','id_dom3d','hall','h',h);
% --- heat flux = power surface density (W/m^2)
th_02.add_ps('id','ps','id_dom3d','up_surface_heat','ps',ps);
% --- power volume density = volumic losses (W/m^3)
th_02.add_pv('id','pv','id_dom3d','alldom','pv',pv);

% --- local time, /!\rule: 1 PhysicalModel <=> 1 local time
ltime_01 = LTime('t0',0,'t_end',4,'dnum',8);
th_02.add_ltime(ltime_01);

%% 
% ---
th_02.solve;
% ---
% figure
% for i = 1:th_02.ltime.it_max
%     th_02.ltime.it = i;
%     th_02.thconductor.plate.plotT; hold on
%     caxis('auto'); colorbar; view(3);
%     % ---
%     pause(1)
%     % ---
%     if i < th_02.ltime.it_max
%         children = get(gca, 'children');
%         delete(children);
%     end
% end

%% base 02

% --- mesh-size
xmsize = 10;
ymsize = 10;
zmsize = 2;

%% mesh1d

m1d_02 = Mesh1d();

% --- x
m1d_02.add_line1d('id','xplate','len',xplate,'dnum',xmsize,'dtype','lin');
% --- y
m1d_02.add_line1d('id','yplate','len',yplate,'dnum',ymsize,'dtype','lin');
% --- z
m1d_02.add_line1d('id','zplate','len',zplate,'dnum',zmsize,'dtype','lin');
m1d_02.add_line1d('id','zexter','len',zplate,'dnum',zmsize,'dtype','lin');

%% mesh2d-quad
m2d_02 = QuadMeshFrom1d('parent_mesh',m1d_02, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x

% --- dom2d
m2d_02.add_vdom('id','platex',...
    'id_xline','x...',...
    'id_yline','y...');

%% mesh3d-hex
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_02,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
m3d_02.add_vdom('id','platex',...
                'id_dom2d','platex',...
                'id_zline','zplate');
m3d_02.add_vdom('id','alldom',...
                'id_dom2d','platex',...
                'id_zline',{'zplate','zexter'});

% -- dom3d-surface
m3d_02.add_sdom('id','hsurfacex',...
                'defined_on','bound_face',...
                'id_dom3d','platex');
m3d_02.add_sdom('id','up_surface_heat',...
                'defined_on','bound_face',...
                'id_dom3d','platex','condition','z = max(z)');
m3d_02.add_sdom('id','hall',...
                'defined_on','bound_face',...
                'id_dom3d','alldom');
%% FEM3dTherm = Model thermic 3d by FEM

% Physical parameters
% in SI base unit
lambda = 20;
rho    = 1000;
cp     = 1000;
h      = 10;
ps     = 0;
pv     = 1e7;

% --- initialization
th_03 = FEM3dTherm('parent_mesh',m3d_02,'T0',20);

% --- add physical dom should be done by using add_... method
th_03.add_thconductor('id','plate','id_dom3d','alldom','lambda',lambda);
th_03.add_thcapacitor('id','plate','id_dom3d','alldom','rho',rho,'cp',cp);
% ---
th_03.add_convection('id','plate_surface','id_dom3d','hall','h',h);
% --- heat flux = power surface density (W/m^2)
th_03.add_ps('id','ps','id_dom3d','up_surface_heat','ps',ps);
% --- power volume density = volumic losses (W/m^3)
th_03.add_pv('id','pv','id_dom3d','alldom','pv',pv);

% --- local time, /!\rule: 1 PhysicalModel <=> 1 local time
ltime_01 = LTime('t0',0,'t_end',4,'dnum',8);
th_03.add_ltime(ltime_01);

%% 
% ---
th_03.solve;





%% models

model01 =  th_01';
% --- same parent_mesh models + same ltime
model02 = model01';

% --- check
% figure
% model01.parent_mesh.plot;
% figure
% model02.parent_mesh.plot;

% --- same parent_mesh models + diff ltime
model03 = th_01b';

% --- diff parent_mesh models + diff ltime + same id_dom
model04 =  th_02';

% --- diff parent_mesh models + diff ltime + diff id_dom
model05 =  th_03';

% --- check
% figure
% model03.parent_mesh.plot;
% figure
% model04.parent_mesh.plot;

%%

% vecfield = [1 1 1].';
for m = 1:5
    eval(['model_ = model0' num2str(m) ';']);
    nb_edge = model_.parent_mesh.nb_edge;
    nb_face = model_.parent_mesh.nb_face;
    for i = 1:length(model_.dof)
        model_.ltime.it = i;
        t = model_.ltime.t_now;
        % ---
        node  = model_.parent_mesh.node;
        % ---
        vface = f_chavec(node,model_.parent_mesh.face);
        sface = model_.parent_mesh.sface;
        ffield = model_.parent_mesh.cface;
        % ---
        vedge = f_chavec(node,model_.parent_mesh.edge);
        ledge = model_.parent_mesh.ledge;
        efield = model_.parent_mesh.cedge;
        % ---
        model_.dof{i}.B = FaceDof('parent_model',model_,'value',t.*sum(vface.*ffield).*sface);
        model_.dof{i}.E = EdgeDof('parent_model',model_,'value',(t*(1+1j)).*sum(vedge.*efield).*ledge);
        model_.field{i}.B.elem = FaceDofBasedVectorElemField('parent_model',model_,'dof',model_.dof{i}.B);
        model_.field{i}.E.elem = EdgeDofBasedVectorElemField('parent_model',model_,'dof',model_.dof{i}.E);
        model_.field{i}.E.face = EdgeDofBasedVectorFaceField('parent_model',model_,'dof',model_.dof{i}.E);
    end
end


%%
% --- save for tuto Param
save sample_models_tuto_Parameter model01 model02 model03 model04 model05;

% --- save for test mesh methods
save meshes m3d_01 m2d_01

return

%% --- Test B.elem
figure; model04.field{2}.B.elem.plot('id_meshdom','plate');
figure; model01.field{3}.B.elem.plot('id_meshdom','plate');

%% --- Test E.elem
figure; model04.field{2}.E.elem.plot('id_meshdom','plate');
figure; model01.field{3}.E.elem.plot('id_meshdom','plate');

%% --- Test E.face
% --- not available in global coordinates yet
% model01.parent_mesh.cface,real(model01.field{3}.E.face.cvalue)
% model04.parent_mesh.cface,real(model04.field{2}.E.face.cvalue)
% ---
model01.field{3}.E.face.inode
model01.field{3}.E.face.inode(model01.parent_mesh.dom.hsurface.gid_face)
% ---
model01.field{3}.E.face.gnode
model01.field{3}.E.face.gnode(model01.parent_mesh.dom.hsurface.gid_face)
% ---
figure; model04.field{2}.E.face.plot('id_meshdom','hsurface');
figure; model01.field{3}.E.face.plot('id_meshdom','hsurface');

%% --- check T model04
figure
for i = 1:model04.ltime.it_max
    model04.ltime.it = i;
    model04.thconductor.plate.plotT; hold on
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < model04.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% --- check T model01
figure
for i = 1:model01.ltime.it_max
    model01.ltime.it = i;
    model01.thconductor.plate.plotT; hold on
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < model01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% --- check T model05
figure
for i = 1:model05.ltime.it_max
    model05.ltime.it = i;
    model05.thconductor.plate.plotT; hold on
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < model05.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end


