
close all
clear all
clc

%% Geo parameters
xplate = 50e-3;
yplate = 10e-3;
zplate = 50e-3;

% --- mesh-size
xmsize = 5;
ymsize = 5;
zmsize = 5;

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
%      taken in order of creation

% --- dom2d
m2d_01.add_vdom('id','plate',...
    'id_xline','x...',...
    'id_yline','y...');

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' may be ommited if same as mesh2d

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

% --- initialization
th_01 = FEM3dTherm('parent_mesh',m3d_01,'T0',20);

% Physical parameters
% in SI base unit
% ---
lambda_01 = Parameter('parent_model',th_01,'f',@(T)(20 .* (1-T./500)),'depend_on','T','from',th_01);
lambda_02 = Parameter('parent_model',th_01,'f',@(T)(20 .* (1-T./500)),'depend_on','T','from',th_01);
lambda_03 = Parameter('parent_model',th_01,'f',@(T)( 5 .* (1-T./500)),'depend_on','T','from',th_01);
lambda = LTensor('parent_model',th_01,...
                     'main_dir',[1 0 0],'main_value',lambda_01,...
                     'ort1_dir',[0 1 0],'ort1_value',lambda_02,...
                     'ort2_dir',[0 0 1],'ort2_value',lambda_03);
% ---
rho = Parameter('parent_model',th_01,'f',@f__rho,'depend_on','T','from',th_01);
cp  = Parameter('parent_model',th_01,'f',@(T)(-(T./10-50).^2+2500),'depend_on','T','from',th_01);
h   = Parameter('parent_model',th_01,'f',@(T)(10+0.1.*T),'depend_on','T','from',th_01);
ps  = Parameter('parent_model',th_01,'f',@(t)(1e5.*abs(sin(2*pi/10*t))),'depend_on','ltime','from',th_01);
pv  = Parameter('parent_model',th_01,'f',@(c)(c(3,:).*2e8),'depend_on','celem','from',th_01);

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
ltime_01 = LTime('t0',0,'t_end',10,'dnum',40);
th_01.add_ltime(ltime_01);

%% Test 00
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    caxis([0 200]); colorbar; view(3);
    % ---
    pause(0.2)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end