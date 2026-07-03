function run_create_test_models()
%--------------------------------------------------------------------------
% Build and save the sample models used by TestParameter.
% Adapted from tutorial/parameter/run_create_model.m :
%   model01 vs. model02 --- same parent_mesh models + same ltime
%   model01 vs. model03 --- same parent_mesh models + diff ltime
%   model01 vs. model04 --- diff parent_mesh models + diff ltime + same id_dom
%
% The models carry :
%   - a solved thermal field T (FEM3dTherm)
%   - synthetic B (FaceDof) and E (EdgeDof, complex) fields built from an
%     analytic space*time expression, so that values are comparable
%     between models whatever the mesh and the time discretization.
%
% champ3d folders must be on the MATLAB path.
%--------------------------------------------------------------------------

%% Geo parameters
xplate = 10;
yplate = 10;
zplate = 2;

%% base mesh 01 (coarse)
m1d_01 = Mesh1d();
m1d_01.add_line1d('id','xplate','len',xplate,'dnum',5,'dtype','lin');
m1d_01.add_line1d('id','yplate','len',yplate,'dnum',5,'dtype','lin');
m1d_01.add_line1d('id','zplate','len',zplate,'dnum',1,'dtype','lin');
% ---
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01,'id_xline','x...','id_yline','y...');
m2d_01.add_vdom('id','plate','id_xline','x...','id_yline','y...');
% ---
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,'id_zline',{'z...'});
m3d_01.add_vdom('id','plate','id_dom2d','plate','id_zline','zplate');
m3d_01.add_sdom('id','hsurface','defined_on','bound_face','id_dom3d','plate');
m3d_01.add_sdom('id','up_surface_heat','defined_on','bound_face',...
                'id_dom3d','plate','condition','z = max(z)');

%% base mesh 02 (finer, larger in z, same id_dom 'plate')
m1d_02 = Mesh1d();
m1d_02.add_line1d('id','xplate','len',xplate,'dnum',10,'dtype','lin');
m1d_02.add_line1d('id','yplate','len',yplate,'dnum',10,'dtype','lin');
m1d_02.add_line1d('id','zplate','len',zplate,'dnum',2,'dtype','lin');
m1d_02.add_line1d('id','zexter','len',zplate,'dnum',2,'dtype','lin');
% ---
m2d_02 = QuadMeshFrom1d('parent_mesh',m1d_02,'id_xline','x...','id_yline','y...');
m2d_02.add_vdom('id','plate','id_xline','x...','id_yline','y...');
% ---
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_02,'id_zline',{'z...'});
m3d_02.add_vdom('id','plate','id_dom2d','plate','id_zline','zplate');
m3d_02.add_vdom('id','alldom','id_dom2d','plate','id_zline',{'zplate','zexter'});
m3d_02.add_sdom('id','hsurface','defined_on','bound_face','id_dom3d','plate');
m3d_02.add_sdom('id','up_surface_heat','defined_on','bound_face',...
                'id_dom3d','plate','condition','z = max(z)');
m3d_02.add_sdom('id','hall','defined_on','bound_face','id_dom3d','alldom');

%% thermal models
% --- reference model
th_01 = local_thmodel(m3d_01,'plate','hsurface',LTime('t0',0,'t_end',1,'dnum',4));
% --- same mesh, different ltime
th_01b = local_thmodel(m3d_01,'plate','hsurface',LTime('t0',0,'t_end',2,'dnum',5));
% --- different mesh, different ltime
th_02 = local_thmodel(m3d_02,'alldom','hall',LTime('t0',0,'t_end',4,'dnum',8));

%% models
model01 = th_01';
% --- same parent_mesh models + same ltime
model02 = model01';
% --- same parent_mesh models + diff ltime
model03 = th_01b';
% --- diff parent_mesh models + diff ltime + same id_dom
model04 = th_02';

%% synthetic B/E dofs and fields (analytic space*time expression)
models = {model01,model02,model03,model04};
for m = 1:length(models)
    model_ = models{m};
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
    model_.ltime.it = 1;
end

%% save next to this file
here = fileparts(mfilename('fullpath'));
save(fullfile(here,'sample_models_testParameter.mat'),...
     'model01','model02','model03','model04');
fprintf('testParameter : sample models saved in %s \n',here);

end

%--------------------------------------------------------------------------
function th = local_thmodel(mesh,id_vol,id_surf,ltime)
% FEM3dTherm model with the physical doms used by the tests
% (same ids as tutorial/parameter : thconductor.plate, convection.plate_surface)
th = FEM3dTherm('parent_mesh',mesh,'T0',20);
% ---
th.add_thconductor('id','plate','id_dom3d',id_vol,'lambda',20);
th.add_thcapacitor('id','plate','id_dom3d',id_vol,'rho',1000,'cp',1000);
th.add_convection('id','plate_surface','id_dom3d',id_surf,'h',10);
th.add_ps('id','ps','id_dom3d','up_surface_heat','ps',0);
th.add_pv('id','pv','id_dom3d',id_vol,'pv',1e7);
% ---
th.add_ltime(ltime);
% ---
th.solve;
end
