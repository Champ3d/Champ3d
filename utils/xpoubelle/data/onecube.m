close all
clear
clc
% ---
c3dobj = [];
% ---
c3dobj = f_add_x(c3dobj,'id_x','x','d',1,'dnum',1,'dtype','lin');
c3dobj = f_add_y(c3dobj,'id_y','y','d',1,'dnum',1,'dtype','lin');
c3dobj = f_add_layer(c3dobj,'id_layer','z','d',1,'dnum',1,'dtype','lin');
% ---
c3dobj = f_add_mesh2d(c3dobj,'id_mesh2d','my_mesh2d','id_x', 'x','id_y','y');
% ---
c3dobj = f_add_dom2d(c3dobj,'id_dom2d','xy','id_x', 'x','id_y', 'y');
% ---
c3dobj = f_add_mesh3d(c3dobj,'id_mesh3d','my_mesh3d','mesher','c3d_hexamesh',...
                       'id_mesh2d','my_mesh2d','id_layer','z');
% ---
c3dobj = f_add_dom3d(c3dobj,'id_dom3d','cube','id_dom2d','xy','id_layer','z');
% ---
figure
f_view_c3dobj(c3dobj,'id_dom2d','xy','face_color',f_color(1),'alpha_value',0.5);  hold on
figure
f_view_c3dobj(c3dobj,'id_dom3d','cube','face_color',f_color(1),'alpha_value',0.5);  hold on

save onecube -v7.3






