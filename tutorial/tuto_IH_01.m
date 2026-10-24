
close all
clear all
clc

%% Parameters
lairbox  = 100e-3;
xplate = 100e-3;
yplate = 100e-3;
zply = 140e-6;
layerorder = [0 45 90 135];
nply = length(layerorder);
% ---
zlsp = 1e-3;
% ---
tcoil  = 5e-3;
lcoil  = 10e-3;
xcoil  = 5e-3;
ycoil  = 5e-3;
zcoil  = 100e-3;
% ---
agap = 2e-3;
% --- mesh-size
msize1 = 5;
msize2 = 4;

%% mesh1d

m1d_01 = Mesh1d();

% --- x
m1d_01.add_line1d('id','xabox01','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','xplat01','len',xplate ,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','xcoil01','len',xcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xplat02','len',lcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xcoil02','len',xcoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','xplat03','len',xplate ,'dnum',msize2,'dtype','log+');
m1d_01.add_line1d('id','xabox02','len',lairbox,'dnum',msize1,'dtype','log+');
% --- y
m1d_01.add_line1d('id','yabox01','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','yplat01','len',yplate ,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','ycoil01','len',ycoil  ,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','yplat02','len',yplate ,'dnum',msize2,'dtype','log+');
m1d_01.add_line1d('id','yabox02','len',lairbox,'dnum',msize1,'dtype','log+');
% --- z
m1d_01.add_line1d('id','zabox_b','len',lairbox,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zlsp','len',zlsp,'dnum',1,'dtype','lin');
for i = 1:nply
    idz_ = ['zply' num2str(i)];
    m1d_01.add_line1d('id',idz_,'len',zply,'dnum',1,'dtype','lin');
end
m1d_01.add_line1d('id','zagap','len',agap,'dnum',2,'dtype','lin');
m1d_01.add_line1d('id','ztcoil','len',tcoil,'dnum',4,'dtype','lin');
m1d_01.add_line1d('id','zlcoil','len',zcoil,'dnum',5,'dtype','log+');
%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x
%      taken in order of creation

% --- dom2d
% 'id' is whatever, 'id_xline/yline' must be exact as in mesh1d
m2d_01.add_vdom('id','coil_face',...
    'id_xline',{'xcoil01','xcoil02','xplat02'},...
    'id_yline',{'ycoil01'});
m2d_01.add_vdom('id','coil_arm',...
    'id_xline',{'xcoil01','xcoil02'},...
    'id_yline',{'ycoil01'});
m2d_01.add_vdom('id','plate',...
    'id_xline',{'xcoil01','xcoil02','xplat01','xplat02','xplat03'},...
    'id_yline',{'ycoil01','yplat01','yplat02'});

%%
figure
m2d_01.plot;
m2d_01.dom.coil_face.plot('face_color','r');
m2d_01.dom.coil_arm.plot('face_color','b');
m2d_01.dom.plate.plot('face_color','m');

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
% coil
m3d_01.add_vdom('id','coil',...
                'id_dom2d',{{'coil_face'},{'coil_arm'}},...
                'id_zline',{{'ztcoil'},{'zlcoil'}});
m3d_01.add_sdom('id','scoil','defined_on','bound','id_dom3d','coil');
% ply
for i = 1:nply
    idz_ = ['zply' num2str(i)];
    idd_ = ['ply' num2str(layerorder(i))];
    m3d_01.add_vdom('id',idd_,...
                'id_dom2d','plate',...
                'id_zline',idz_);
end
% lsp
m3d_01.add_vdom('id','lsp',...
                'id_dom2d','plate',...
                'id_zline','zlsp');
% whole plate
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline',{'zply...','zlsp'});
m3d_01.add_sdom('id','surface_plate',...
                'defined_on','bound',...
                'id_dom3d','plate');
% centering coordinates
m3d_01.centering('coil');
%%
figure
%m3d_01.plot('face_color','none','alpha',0.1);
m3d_01.dom.coil.plot;
m3d_01.dom.plate.plot("face_color",'none');
m3d_01.dom.lsp.plot("face_color",f_color(3));

%% Create models
fr = 1e6;
em_01 = FEM3dAphijw('parent_mesh',m3d_01,'frequency',fr);
th_01 = FEM3dTherm('parent_mesh',m3d_01,'T0',25);

% time
ltime = LTime('t0',0,'t_end',20,'dnum',20);
th_01.add_ltime(ltime);

%% Config EM model
% --- coil
em_01.add_sibc('id','coil','id_dom3d','scoil','sigma',1e7);
em_01.add_nomesh('id','coil','id_dom3d','coil');
coil_01 = SolidOpenIsCoil('parent_model',em_01,...
                  'id_dom3d','coil',...
                  'etrode_equation',{'x > 0 & z = max(z)','x < 0 & z = max(z)'},...
                  'Is',250);
em_01.add_coil('id','mycoil','coil_obj',coil_01);
% --- lsp
em_01.add_econductor("id","lsp","id_dom3d","lsp","sigma",1e3);
% --- ply
%param_sigma = ScalarParameter('parent_model',em_01,'f',@(T)(40e3.*(1-T./500)),'depend_on','T','from',th_01);
param_sigma = 40e3;
tsig = [];
for i = 1:nply
    idd_ = ['ply' num2str(layerorder(i))];
    tsig{i} = LTensor('parent_model',em_01, ...
                       'main_dir',[1 0 0],'main_value',param_sigma, ...
                       'ort1_dir',[0 1 0],'ort1_value',10, ...
                       'ort2_dir',[0 0 1],'ort2_value',10, ...
                       'rot_axis',[0 0 1],'rot_angle',layerorder(i));
    em_01.add_econductor("id",idd_,"id_dom3d",idd_,"sigma",tsig{i});
end

%% Config TH model

% convection
h = ScalarParameter('parent_model',th_01,'f',@(T)(5+T/100),'depend_on','T','from',th_01);
th_01.add_convection('id','plate','id_dom3d','surface_plate','h',h);
% conduction
lambda = ScalarParameter('parent_model',th_01,'f',@(T)(10*(1+T/1000)),'depend_on','T','from',th_01);
tlamb = [];
for i = 1:nply
    idd_ = ['ply' num2str(layerorder(i))];
    tlamb{i} = LTensor('parent_model',th_01, ...
                       'main_dir',[1 0 0],'main_value',lambda, ...
                       'ort1_dir',[0 1 0],'ort1_value',1, ...
                       'ort2_dir',[0 0 1],'ort2_value',1, ...
                       'rot_axis',[0 0 1],'rot_angle',layerorder(i));
    th_01.add_thconductor("id",idd_,"id_dom3d",idd_,"lambda",tlamb{i});
end
% ---
th_01.add_thconductor('id','lsp','id_dom3d','lsp','lambda',100);
% mass
th_01.add_thcapacitor('id','plate','id_dom3d','plate','cp',1000,'rho',1000);
th_01.add_thcapacitor('id','lsp','id_dom3d','lsp','cp',1000,'rho',1000);
% heat
pv = ScalarParameter('parent_model',th_01,'f',@(x)(x),'depend_on','P','from',em_01);
th_01.add_pv('id','pv','id_dom3d','plate','pv',pv);

%% solve EM + TH

% if EM linear
em_01.solve;
th_01.solve;

% if EM non-linear
% em_01.add_ltime(ltime);
% for it = 1:length(ltime.t_array)
%     th_01.solveone("it",it);
%     em_01.solveone("it",it);
% end

return
%% EM fields

figure
em_01.field{1}.J.elem.plot('id_meshdom','ply0'); hold on

figure
em_01.field{1}.J.elem.plot('id_meshdom','lsp'); hold on

%% TH fields
figure
for t = th_01.ltime.t_array
    th_01.ltime.it = th_01.ltime.back_it(t);
    th_01.convection.plate.plotT; hold on
    %caxis('auto'); colorbar; view(3);
    %caxis([25 80]); colorbar; view(3);
    % ---
    pause(0.5)
    % ---
    if t < th_01.ltime.t_end
        children = get(gca, 'children');
        delete(children);
    end
end

%%
figure
for t = th_01.ltime.t_array
    th_01.ltime.it = th_01.ltime.back_it(t);
    th_01.thconductor.lsp.plotT; hold on
    % ---
    pause(0.5)
    % ---
    if t < th_01.ltime.t_end
        children = get(gca, 'children');
        delete(children);
    end
end

