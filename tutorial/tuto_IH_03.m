
close all
clear all
clc

%% Parameters
lairbox  = 100e-3;
xplate = 20e-3;
yplate = 100e-3;
zplate = 1e-3;
nplate = 2;
% ---
tcoil  = 5e-3;
xcoil  = 20e-3;
ycoil  = 10e-3;
zcoil  = 100e-3;
% ---
agap = 2e-3;
% --- mesh-size
msize1 = 5;
msize2 = 4;

%% mesh1d

m1d_01 = Mesh1d();

% --- x
m1d_01.add_line1d('id','xabox_l','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','xcoil01','len',tcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xcoil02','len',xcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xcoil03','len',tcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xabox_r','len',lairbox,'dnum',msize1,'dtype','log+');
% --- y
m1d_01.add_line1d('id','yabox_b','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','ycoil01','len',tcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','ycoil02','len',ycoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','ycoil03','len',tcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','yabox_t','len',lairbox,'dnum',msize1,'dtype','log+');
% --- z
m1d_01.add_line1d('id','zabox_b','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zcoil01','len',tcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','zcoil02','len',zcoil  ,'dnum',msize2,'dtype','log=');

%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x
%      taken in order of creation

% --- dom2d
% 'id' is whatever, 'id_xline/yline' must be exact as in mesh1d
m2d_01.add_vdom('id','coil_face',...
    'id_xline',{{'xcoil01','xcoil02','xcoil03'},{'xcoil01'}},...
    'id_yline',{{'ycoil01','ycoil03'},{'ycoil02'}});
m2d_01.add_vdom('id','coil_arm',...
    'id_xline',{'xcoil03'},...
    'id_yline',{'ycoil01','ycoil03'});
%%
figure
m2d_01.plot;
m2d_01.dom.coil_face.plot('face_color','r');
m2d_01.dom.coil_arm.plot('face_color','b');

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
m3d_01.add_vdom('id','coil_face',...
                'id_dom2d','coil_face',...
                'id_zline','zcoil01');
m3d_01.add_vdom('id','coil',...
                'id_dom2d',{{'coil_face'},{'coil_arm'}},...
                'id_zline',{{'zcoil01'},{'zcoil02'}});
m3d_01.add_sdom('id','scoil','defined_on','bound','id_dom3d','coil');

m3d_01.centering('coil_face');
m3d_01.lock_origin('gcoordinates',[xcoil/2  0  tcoil/2 + agap]);
%%
figure
m3d_01.plot('face_color','none','alpha',0.1);
m3d_01.dom.coil.plot;



%% mesh1d

m1d_02 = Mesh1d();

% --- x
m1d_02.add_line1d('id','xabox_l','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_02.add_line1d('id','xplate' ,'len',xplate ,'dnum',msize2,'dtype','log=');
m1d_02.add_line1d('id','xabox_r','len',lairbox,'dnum',msize1,'dtype','log+');
% --- y
m1d_02.add_line1d('id','yabox_b','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_02.add_line1d('id','yplate' ,'len',yplate ,'dnum',2*msize2,'dtype','log=');
m1d_02.add_line1d('id','yabox_t','len',lairbox,'dnum',msize1,'dtype','log+');
% --- z
m1d_02.add_line1d('id','zabox_b','len',lairbox,'dnum',msize1,'dtype','log-');
for i = 1:nplate
    id_ = ['zplate_' num2str(i)];
    m1d_02.add_line1d('id',id_,'len',zplate,'dnum',1,'dtype','lin');
end
m1d_02.add_line1d('id','zabox_t','len',lairbox,'dnum',msize2,'dtype','log+');

%% mesh2d-quad
m2d_02 = QuadMeshFrom1d('parent_mesh',m1d_02, ...
           'id_xline','x...',...
           'id_yline','y...');

% --- dom2d
m2d_02.add_vdom('id','plate',...
    'id_xline','xplate',...
    'id_yline','yplate');
% ---
m2d_02.centering('plate');

%% mesh3d-hex
m3d_02 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_02,...
                              'id_zline',{'z...'});

% --- dom3d-volume
m3d_02.add_vdom('id','copper',...
                'id_dom2d','plate',...
                'id_zline','zplate_1');
m3d_02.add_vdom('id','cfrp',...
                'id_dom2d','plate',...
                'id_zline','zplate_2');
m3d_02.add_sdom('id','scopper','defined_on','bound','id_dom3d','copper');
% ---
m3d_02.centering('cfrp');
m3d_02.lock_origin('gcoordinates',[0 +yplate/2 -zplate*nplate/2]);
%%
figure
m3d_01.dom.coil.plot('face_color',f_color(1));
m3d_02.dom.cfrp.plot('face_color',f_color(2));
m3d_02.dom.copper.plot('face_color',f_color(3));
%%
fr = 1e5;
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
em_01.add_sibc('id','coil','id_dom3d','scoil','sigma',1e7);
em_01.add_nomesh('id','coil','id_dom3d','coil');

coil_01 = SolidOpenIsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'y > 0 & z = max(z)','y < 0 & z = max(z)'},...
                  'Is',250);
em_01.add_coil('id','mycoil','coil_obj',coil_01);

em_01.solve;


%% 
sigma_copper = 1e7;

em_02 = FEM3dAphijw('parent_mesh',m3d_02,'frequency',em_01.frequency);

em_02.add_sibc('id','copper','id_dom3d','scopper','sigma',sigma_copper);
em_02.add_nomesh('id','copper','id_dom3d','copper');

%param_sigma = ScalarParameter('f',40e3,'depend_on','T','from',th_01);
param_sigma = 43e3;
tensor_sigma = LTensor('parent_model',em_02, ...
                       'main_dir',[1 0 0],'main_value',param_sigma, ...
                       'ort1_dir',[0 1 0],'ort1_value',param_sigma, ...
                       'ort2_dir',[0 0 1],'ort2_value',10);
em_02.add_econductor('id','plate','id_dom3d','cfrp','sigma',tensor_sigma);

bs = VectorParameter('parent_model',em_02,'f',@(x)(x),'depend_on','B','from',em_01);
em_02.add_bsfield('id','bsfield','bs',bs);

ltime = LTime('t0',0,'t_end',10,'dnum',5);
em_02.add_ltime(ltime);

speed = 10e-3; % m/s
step = ScalarParameter('f',@(t)(speed * t),'depend_on','ltime','from',em_02);
movframe = LinearMovingFrame('dir',[0 -1 0],'step',step);

em_02.add_movingframe(movframe);

em_02.solve;


%%
figure
em_02.field{5}.J.face.plot('id_meshdom','scopper'); hold on

%%
figure
em_02.field{5}.J.elem.plot('id_meshdom','cfrp'); hold on

%%
figure
em_02.field{5}.P.elem.plot('id_meshdom','cfrp'); hold on

%%
figure
em_02.field{5}.P.face.plot('id_meshdom','scopper'); hold on


%%
m3d_02.add_vdom('id','allplate',...
                'id_dom2d','plate',...
                'id_zline','zplate...');
m3d_02.add_sdom('id','s_allplate','defined_on','bound','id_dom3d','allplate');

%%
th_01 = FEM3dTherm('parent_mesh',em_02.parent_mesh,'T0',25);


th_01.parent_mesh.add_vdom('id','allplate',...
                'id_dom2d','plate',...
                'id_zline','zplate...');
th_01.parent_mesh.add_sdom('id','s_allplate','defined_on','bound','id_dom3d','allplate');


ltime = LTime('t0',0,'t_end',10,'dnum',20);
th_01.add_ltime(ltime);

% --- 1 model - 1 moving-frame (because defend on ltime)
step = ScalarParameter('f',@(t)(10e-3 * t),'depend_on','ltime','from',th_01);
movframe = LinearMovingFrame('dir',[0 -1 0],'step',step);
th_01.add_movingframe(movframe);

h = ScalarParameter('f',@(T)(5+T/100),'depend_on','T','from',th_01);
lambda = ScalarParameter('parent_model',th_01,'f',@(T)(10*(1+T/1000)),'depend_on','T','from',th_01);
tensor_lambda = LTensor('parent_model',th_01, ...
                       'main_dir',[1 0 0],'main_value',lambda, ...
                       'ort1_dir',[0 1 0],'ort1_value',lambda, ...
                       'ort2_dir',[0 0 1],'ort2_value',10);


th_01.add_convection('id_dom3d','s_allplate','h',h);
th_01.add_thconductor('id','cfrp','id_dom3d','cfrp','lambda',tensor_lambda);
th_01.add_thcapacitor('id','cfrp','id_dom3d','cfrp','cp',1000,'rho',1000);
th_01.add_thconductor('id','copper','id_dom3d','copper','lambda',100);
th_01.add_thcapacitor('id','copper','id_dom3d','copper','cp',1000,'rho',1000);

pv = ScalarParameter('parent_model',th_01,'f',@(x)(x),'depend_on','P','from',em_02);
th_01.add_pv('id','pv','id_dom3d','cfrp','pv',pv);
ps = ScalarParameter('parent_model',th_01,'f',@(x)(x),'depend_on','P','from',em_02);
th_01.add_ps('id','ps','id_dom3d','scopper','ps',ps);

th_01.solve;

%% ---

figure
for t = 0:0.2:10
    th_01.ltime.it = th_01.ltime.back_it(t);
    th_01.thconductor.copper.plotT; hold on
    em_01.ltime.it = th_01.ltime.back_it(t);
    em_01.coil.mycoil.plot('alpha',0.5,'face_color','b','edge_color','none');
    %caxis('auto'); colorbar; view(3);
    caxis([25 50]); colorbar; view(3);
    % ---
    pause(0.5)
    % ---
    if t < th_01.ltime.t_end
        children = get(gca, 'children');
        delete(children);
    end
end



