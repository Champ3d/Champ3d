function arglist = f_arglist(arglistcase)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list

switch arglistcase
    case {'add_dom3d','adddom3d','f_add_dom3d'}
        arglist = {'id_mesh3d','id_dom3d','id_dom2d','id_layer','elem_code', ...
                   'defined_on','of_dom3d',...
                   'get','n_direction','n_component'};
               
    case {'getmeshobj','get_meshobj','f_get_meshobj'}
        arglist = {'id_mesh2d','id_dom2d',...
                   'id_mesh3d','id_dom3d',...
                   'of_dom3d',...
                   'id_emdesign3d','id_thdesign3d', ...
                   'id_econductor','id_mconducteur',...
                   'id_coil','id_bc','id_nomesh',...
                   'id_bsfield','id_pmagnet',...
                   'id_tconductor','id_tcapacitor',...
                   'get',...
                   'n_direction','n_component'};
               
    case {'getedge','get_edge','f_get_edge'}
        arglist = f_arglist('getmeshobj');
        
    case {'getedgeinelem','get_edge_in_elem','f_get_edge_in_elem'}
        arglist = f_arglist('getmeshobj');
        
    case {'getedgeinface','get_edge_in_face','f_get_edge_in_face'}
        arglist = f_arglist('getmeshobj');
        
    case {'getface','get_face','f_get_face'}
        arglist = f_arglist('getmeshobj');
        
    case {'getfaceinelem','get_face_in_elem','f_get_face_in_elem'}
        arglist = f_arglist('getmeshobj');
        
    case {'get_bound_face','getboundface','f_get_bound_face'}
        arglist = f_arglist('getmeshobj');
        
    case {'get_inter_face','getinterface','f_get_inter_face'}
        arglist = f_arglist('getmeshobj');
        
    case {}
        arglist = {};
    case {}
        arglist = {};
end

