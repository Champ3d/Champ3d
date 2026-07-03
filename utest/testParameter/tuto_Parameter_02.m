
close all
clear all
clc

%% Model data
% model01 vs. model02 --- same parent_mesh models + same ltime
% model01 vs. model03 --- same parent_mesh models + diff ltime
% model01 vs. model04 --- diff parent_mesh models + diff ltime

load sample_models_tuto_Parameter.mat

%% Parameters

% --- Use anonymous functions or function handle via @
% --- if function is vectorized, tell it to Parameter
param_00 = 1e6;
param_01 = ScalarParameter('parent_model',model01,'f',@(x)(x + 1),'depend_on','T','from',model01);
param_02 = ScalarParameter('parent_model',model01,'f',@(x)(x + 1),'depend_on','T','from',model02);
param_04 = ScalarParameter('parent_model',model01,'f',@(x)(x + 1),'depend_on','T','from',model03);
param_07 = ScalarParameter('parent_model',model01,'f',@(x)(x + 1),'depend_on','T','from',model04);
param_13 = ScalarParameter('parent_model',model01,'f',@(x)(x + 1),'depend_on','T','from',model05);
% ---
param_03 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','B'},'from',{model01,model02});
param_05 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','B'},'from',{model03,model03});
param_09 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','B'},'from',{model03,model04});
param_15 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','B'},'from',{model03,model05});
% ---
param_06 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','E'},'from',{model03,model02});
param_10 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','E'},'from',{model01,model04});
param_16 = ScalarParameter('parent_model',model01,'f',@(x,y)(x + norm(y)),...
           'depend_on',{'T','E'},'from',{model01,model05});
% ---
param_11 = VectorParameter('parent_model',model01,'f',@(x)(x),'depend_on','E','from',model01);
param_12 = VectorParameter('parent_model',model01,'f',@(x)(x),'depend_on','E','from',model04);
% ---
param_08 = VectorParameter('parent_model',model01,'f',@(x)(x),'depend_on','B','from',model04);
param_14 = VectorParameter('parent_model',model01,'f',@(x)(x),'depend_on','B','from',model05);

% --- Able to customized complex dependency
param_17 = VectorParameter('parent_model',model01,'f',@f__customized,'depend_on','celem','from',model01,...
                     'fvectorized',0,...
                     'varargin_list',{'fx',@(x,y,z)(x),'fy',@(x,y,z)(y),'fz',@(x,y,z)(z),'s',[0 0 1]});

% --- LVector
% --- able to use Parameter object
lvector_00 = [1 0 0];
lvector_01 = LVector('parent_model',model01,'main_dir',[1 0 0],'main_value',1);
lvector_02 = LVector('parent_model',model01,'main_dir',[0 1 0],'main_value',param_10);
lvector_03 = LVector('parent_model',model01,'main_dir',param_17,'main_value',param_10);
lvector_04 = LVector('parent_model',model01,'main_dir',param_17,'main_value',param_10,...
                     'rot_axis',[0 0 1],'rot_angle',90);

% --- LTensor
% --- able to use Parameter object

p01 = Parameter('parent_model',model01,'f',@(c,T)(T * [1 0 0]),'depend_on',{'celem','T'},'from',{model01,model02});
p02 = Parameter('parent_model',model01,'f',@(c,T)(T * [0 1 0]),'depend_on',{'celem','T'},'from',{model01,model03});
p03 = Parameter('parent_model',model01,'f',@(c,T)(T * [0 0 1]),'depend_on',{'celem','T'},'from',{model01,model04});

ltensor_00 = [1  4  0; ...
              4  2  0; ...
              0  0  3];
ltensor_01 = LTensor('parent_model',model01,...
                     'main_dir',[1 0 0].','main_value',1,...
                     'ort1_dir',[0 1 0].','ort1_value',2,...
                     'ort2_dir',[0 0 1],'ort2_value',3);
ltensor_02 = LTensor('parent_model',model01,...
                     'main_dir',p01,'main_value',1,...
                     'ort1_dir',p02,'ort1_value',2,...
                     'ort2_dir',p03,'ort2_value',3);
ltensor_03 = LTensor('parent_model',model01,...
                     'main_dir',lvector_01,'main_value',param_09,...
                     'ort1_dir',lvector_02,'ort1_value',param_10,...
                     'ort2_dir',[0 0 1].','ort2_value',param_01);
%% dom to get
vdom = model01.thconductor.plate;
sdom = model01.convection.plate_surface;


return


%% get --- run by section
model01.ltime.it = 3;
p_array_01a = param_01.getvalue('in_dom',vdom);
p_array_01b = param_01.getvalue('in_dom',sdom);
p_array_02a = param_02.getvalue('in_dom',vdom);
p_array_02b = param_02.getvalue('in_dom',sdom);
p_array_03  = param_03.getvalue('in_dom',vdom);
p_array_04a = param_04.getvalue('in_dom',sdom);
p_array_04b = param_04.getvalue('in_dom',vdom);
p_array_05  = param_05.getvalue('in_dom',vdom);
p_array_06a = param_06.getvalue('in_dom',vdom);
p_array_06b = param_06.getvalue('in_dom',sdom);
p_array_07a = param_07.getvalue('in_dom',vdom);
p_array_07b = param_07.getvalue('in_dom',sdom);
% ---
p_array_08a = param_08.getvalue('in_dom',vdom);
% p_array_08b = param_08.getvalue('in_dom',sdom);
% figure
% subplot(121)
% model04.field{2}.B.elem.plot('id_meshdom','plate')
% subplot(122)
% f_quiver(model01.parent_mesh.celem(:,vdom.gindex),p_array_08);
% ---
p_array_09  = param_09.getvalue('in_dom',vdom);
p_array_10a = param_10.getvalue('in_dom',vdom);
p_array_10b = param_10.getvalue('in_dom',sdom);

% ---
p_array_11a = param_11.getvalue('in_dom',vdom);
p_array_11b = param_11.getvalue('in_dom',sdom);
% ---
figure
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),real(p_array_11a));
% ---
figure
cf = model01.parent_mesh.cface(:,sdom.dom.gindex);
ce = model01.parent_mesh.celem(:,vdom.dom.gindex);
subplot(121)
v = Array.norm(p_array_11b); s = v; c = v; 
scatter3(cf(1,:),cf(2,:),cf(3,:),100.*s,c,'filled'); colorbar
subplot(122)
v = Array.norm(p_array_11a); s = v; c = v; 
scatter3(ce(1,:),ce(2,:),ce(3,:),100.*s,c,'filled'); colorbar
% ---
p_array_13a = param_13.getvalue('in_dom',vdom);
p_array_13b = param_13.getvalue('in_dom',sdom);
p_array_14a = param_14.getvalue('in_dom',vdom);
p_array_15a = param_15.getvalue('in_dom',vdom);
p_array_16a = param_16.getvalue('in_dom',vdom);
p_array_16b = param_16.getvalue('in_dom',sdom);

% ---
p_array_17 = param_17.getvalue('in_dom',vdom);
% figure
% f_quiver(model01.parent_mesh.celem(:,vdom.gindex),p_array_17);

%% ---
figure
plot(p_array_01a); hold on
plot(p_array_02a)
plot(p_array_04a)
plot(p_array_07a)
plot(p_array_13a)

%% ---
figure
plot(p_array_01b); hold on
plot(p_array_02b)
plot(p_array_04b)
plot(p_array_07b)
plot(p_array_13b)

%% ---
figure
plot(p_array_03); hold on
plot(p_array_05)
plot(p_array_09)
plot(p_array_15a)

%% ---
figure
plot(p_array_06a); hold on
plot(p_array_10a)
plot(p_array_16a)

%% --- !!!
figure
plot(p_array_06b); hold on
plot(p_array_10b)
plot(p_array_16b)

%% get --- run by section
model01.ltime.it = 5;
% ---
v_array_01 = lvector_01.getvalue('in_dom',vdom);
v_array_xi = lvector_01.get_inverse('in_dom',vdom);
figure
subplot(121)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_01);
subplot(122)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_xi);
% ---
v_array_02 = lvector_02.getvalue('in_dom',vdom);
v_array_xi = lvector_02.get_inverse('in_dom',vdom);
figure
subplot(121)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_02);
subplot(122)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_xi);
% ---
v_array_03 = lvector_03.getvalue('in_dom',vdom);
v_array_xi = lvector_03.get_inverse('in_dom',vdom);
figure
subplot(121)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_03);
subplot(122)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_xi);
% ---
v_array_04 = lvector_04.getvalue('in_dom',vdom);
v_array_xi = lvector_04.get_inverse('in_dom',vdom);
figure
subplot(121)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_04);
subplot(122)
f_quiver(model01.parent_mesh.celem(:,vdom.dom.gindex),v_array_xi);

%% get --- run by section
t_array_01 = ltensor_01.getvalue('in_dom',vdom);
t_array_01i = ltensor_01.get_inverse('in_dom',vdom);
t_array_02 = ltensor_02.getvalue('in_dom',vdom);
t_array_02i = ltensor_02.get_inverse('in_dom',vdom);
t_array_03 = ltensor_03.getvalue('in_dom',vdom);
t_array_03i = ltensor_03.get_inverse('in_dom',vdom);

for i = 1:size(t_array_01,1)
    prod = squeeze(t_array_01(i,:,:)) * squeeze(t_array_01i(i,:,:));
    if ~(isdiag(prod) && (det(prod) - 1) < 1e-9)
        warning('not equal');
    end
end

for i = 1:size(t_array_03,1)
    prod = squeeze(t_array_03(i,:,:)) * squeeze(t_array_03i(i,:,:));
    if ~(isdiag(prod) && (det(prod) - 1) < 1e-9)
        warning('not equal');
    end
end
%% Test
figure; model01.field{5}.T.node.plot('id_meshdom','plate')
figure; model01.field{5}.T.elem.plot('id_meshdom','plate')
figure; model01.field{5}.T.face.plot('id_meshdom','hsurface')
% model01.field{5}.T.elem.ivalue
% model01.field{5}.T.face.ivalue

