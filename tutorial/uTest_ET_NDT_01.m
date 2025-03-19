%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

close all
clear all
clc

%% Parameters

riCoil = 2e-3;
roCoil = 4e-3;
zCoil  = 2e-3;
rPlate = 10e-3;
zPlate = 2e-3;
airgap = 1e-3;
sigPlate = 1e6;
murPlate = 1;
rBox = 2*rPlate;
%% mesh1d

m1d_01 = Mesh1d();
% ---
msize1 = 1;
msize2 = 1;
% --- x
m1d_01.add_line1d('id','xabox_l','len',rBox - rPlate,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','xplate_l','len',rPlate - roCoil,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','xcoil_ol','len',roCoil - riCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xcoil_i','len',riCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xcoil_or','len',roCoil - riCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','xplate_r','len',rPlate - roCoil,'dnum',msize1,'dtype','log+');
m1d_01.add_line1d('id','xabox_r','len',rBox - rPlate,'dnum',msize2,'dtype','log+');
% --- y
id_xline = fieldnames(m1d_01.dom);
for i = 1:length(id_xline)
    id_yline = replace(id_xline{i},'x','y');
    m1d_01.dom.(id_yline) = m1d_01.dom.(id_xline{i})';
end
% --- z
m1d_01.add_line1d('id','zabox_b','len',rBox,'dnum',msize2,'dtype','log-');
m1d_01.add_line1d('id','zplate'  ,'len',zPlate,'dnum',msize1,'dtype','log-');
m1d_01.add_line1d('id','zagap'  ,'len',airgap,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zcoil'  ,'len',zCoil,'dnum',msize1,'dtype','lin');
m1d_01.add_line1d('id','zabox_t','len',rBox,'dnum',msize2,'dtype','log+');

%% mesh2d-quad
m2d_01 = QuadMeshFrom1d('parent_mesh',m1d_01, ...
           'id_xline','x...',...
           'id_yline','y...');
% --- dom2d
m2d_01.add_vdom('id','plate',...
    'id_xline',{'xplate_l','xcoil_ol','xcoil_i','xcoil_or','xplate_r'},...
    'id_yline',{'yplate_l','ycoil_ol','ycoil_i','ycoil_or','yplate_r'});
m2d_01.add_vdom('id','coil',...
    'id_xline',{{'xcoil_ol','xcoil_or'},          {'xcoil_ol','xcoil_or'}},...
    'id_yline',{{'ycoil_ol','ycoil_i','ycoil_or'},{'ycoil_i'}});

%% mesh3d-hex
m3d_01 = HexaMeshFromQuadMesh('parent_mesh2d',m2d_01,...
                              'id_zline',{'z...'});

% --- dom3d-volume
m3d_01.add_vdom('id','plate',...
                'id_dom2d','plate',...
                'id_zline','zplate');
m3d_01.add_vdom('id','coil',...
                'id_dom2d','coil',...
                'id_zline','zcoil');
% -- dom3d-surface
m3d_01.add_sdom('id','surface_plate',...
                'defined_on','bound_face',...
                'id_dom3d','plate');

%% plot mesh

% --- 2d mesh
figure
m2d_01.dom.plate.plot('face_color','c'); hold on
m2d_01.dom.coil.plot('face_color','b')
% --- 3d mesh
figure
m3d_01.dom.plate.plot('face_color','c'); hold on
m3d_01.dom.coil.plot('face_color','b')


















