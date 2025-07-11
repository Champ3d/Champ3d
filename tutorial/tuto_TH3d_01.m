
close all
clear all
clc

%% Geo parameters
wplat = 10e-3;
wheat = 10e-3;
zplat = 10e-3;
zheat = 10e-3;
% --- mesh-size
msize1 = 2;
msize2 = 2;

%% mesh1d

m1d_01 = Mesh1d();

% --- x
m1d_01.add_line1d('id','xplat_l','len',wplat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xray_l' ,'len',wheat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xheat'  ,'len',wheat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xray_r' ,'len',wheat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xplat_r','len',wplat,'dnum',msize1,'dtype','lin');
% --- y
m1d_01.add_line1d('id','yplat_b','len',wplat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','yheat'  ,'len',wheat,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','yplat_t','len',wplat,'dnum',msize1,'dtype','lin');
% --- z
m1d_01.add_line1d('id','zheat_b','len',zheat,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','zplat'  ,'len',zplat,'dnum',msize2,'dtype','lin');
m1d_01.add_line1d('id','zheat_t','len',zheat,'dnum',msize2,'dtype','lin');

%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% x... means all valid id in mesh1d beginning with x
%      taken in order of creation

% --- dom2d
% 'id' is whatever, 'id_xline/yline' must be exact as in mesh1d
m2d_01.add_vdom('id','alldom',...
    'id_xline',{{'x...'},{'xplat_l','xheat','xplat_r'}},...
    'id_yline',{{'yplat_b','yplat_t'},{'yheat'}});
m2d_01.add_vdom('id','heat',...
    'id_xline','xheat',...
    'id_yline','yheat');
% --- new dom based on others by (-, +, ^) operators
% m2d_01.dom.plate = m2d_01.dom.alldom - m2d_01.dom.heat;
m2d_01.add_vdom('id','plate','dom_obj',m2d_01.dom.alldom - m2d_01.dom.heat);

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});
% 'parent_mesh1d' can be ommited if same as mesh2d

% --- dom3d-volume
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplat');
m3d_01.add_vdom('id','heat',...
                'id_dom2d','heat',...
                'id_zline','z...');
% --- new dom based on others by (-, +, ^) operators
% m3d_01.dom.alldom = m3d_01.dom.plate + m3d_01.dom.heat;
m3d_01.add_vdom('id','alldom','dom_obj',m3d_01.dom.plate + m3d_01.dom.heat);

% -- dom3d-surface
m3d_01.add_sdom('id','hsurface',...
                'defined_on','bound_face',...
                'id_dom3d','alldom');
m3d_01.add_sdom('id','bound_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');
m3d_01.add_sdom('id','bound_heat',...
                'defined_on','bound_face',...
                'id_dom3d','heat');
m3d_01.add_sdom('id','up_surface_heat',...
                'defined_on','bound_face',...
                'id_dom3d','heat','condition','z = max(z)');

% --- new dom based on others by (-, +, ^) operators
% m3d_01.dom.contact = m3d_01.dom.bound_heat ^ m3d_01.dom.bound_plate;
m3d_01.add_sdom('id','contact','dom_obj',m3d_01.dom.bound_heat ^ m3d_01.dom.bound_plate);
%% FEM3dTherm = Model thermic 3d by FEM

% --- initialization
th_01 = FEM3dTherm('parent_mesh',m3d_01,'T0',20);

% Physical parameters
% in SI base unit
lambda = 20;
rho    = 1000;
cp     = 1000;
h      = 10;
ps     = 1e3;
pv     = 1e6;


% --- add physical dom should be done by using add_... method
th_01.add_thconductor('id','plate','id_dom3d','plate','lambda',lambda);
th_01.add_thcapacitor('id','plate','id_dom3d','plate','rho',rho,'cp',cp);
% ---
th_01.add_thconductor('id','heat','id_dom3d','heat','lambda',lambda);
th_01.add_thcapacitor('id','heat','id_dom3d','heat','rho',rho,'cp',cp);
% ---
th_01.add_convection('id','allbound','id_dom3d','hsurface','h',h);
% --- heat flux = power surface density (W/m^2)
th_01.add_ps('id','ps','id_dom3d','up_surface_heat','ps',ps);
% --- power volume density = volumic losses (W/m^3)
th_01.add_pv('id','pv','id_dom3d','heat','pv',pv);
% --- not physical / visualization dom
th_01.add_visualdom('id','contact','id_dom3d','contact');

% --- local time, /!\rule: 1 PhysicalModel <=> 1 local time
ltime_01 = LTime('t0',0,'t_end',30,'dnum',3);
th_01.add_ltime(ltime_01);

%% save
save th_01 th_01 m3d_01 m2d_01 m1d_01



return



%% ---
figure
subplot(131)
th_01.thconductor.plate.plot('face_color',f_color(1)); hold on
th_01.thconductor.heat.plot('face_color',f_color(2));
subplot(132)
th_01.convection.allbound.plot('face_color',f_color(1));
subplot(133)
th_01.ps.ps.plot('face_color',f_color(1)); hold on
th_01.pv.pv.plot('face_color',f_color(2));


%% ---
figure
th_01.convection.allbound.plot('face_color',f_color(2));


%% Test 00
% ---
th_01.solve;

% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(0.5)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%%
figure
subplot(141)
th_01.field{4}.T.node.plot('id_meshdom','plate')
subplot(142)
th_01.field{4}.T.node.plot('id_meshdom','hsurface')
subplot(143)
th_01.field{4}.T.node.plot('id_elem',m3d_01.dom.plate.gindex)
subplot(144)
th_01.field{4}.T.node.plot('id_meshdom','contact');

%%
figure
subplot(141)
th_01.field{4}.T.elem.plot('id_meshdom','plate')
subplot(142)
th_01.field{4}.T.elem.plot('id_meshdom','heat')
subplot(143)
th_01.field{4}.T.elem.plot('id_elem',m3d_01.dom.plate.gindex)
subplot(144)
th_01.field{4}.T.elem.plot('id_elem',m3d_01.dom.heat.gindex)

%% Test 01
th_01.ps.ps.ps = 0;
th_01.ps.ps.reset;
th_01.thconductor.plate.lambda = 10;
th_01.thconductor.plate.reset;
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 02
th_01.thconductor.plate.lambda = 100;
th_01.thconductor.plate.reset;
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 03
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 04
close all
clear all

load th_01

m1d_01.dom.xheat.len = m1d_01.dom.xheat.len/4;
m1d_01.dom.xheat.reset;
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 05
th_01.ps.ps.ps = ps;
th_01.ps.ps.reset;
th_01.pv.pv.pv = 0;
th_01.pv.pv.reset;
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 06
th_01.ps.ps.dom.condition = 'z = min(z)';
th_01.ps.ps.dom.reset;
th_01.pv.pv.pv = 0;
th_01.pv.pv.reset;
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end

%% Test 07
th_01.add_ps('id','ps','id_dom3d','up_surface_heat','ps',1e4);
% ---
th_01.solve;
% ---
figure
for i = 1:th_01.ltime.it_max
    th_01.ltime.it = i;
    th_01.thconductor.plate.plotT; hold on
    th_01.thconductor.heat.plotT;
    caxis('auto'); colorbar; view(3);
    % ---
    pause(1)
    % ---
    if i < th_01.ltime.it_max
        children = get(gca, 'children');
        delete(children);
    end
end
