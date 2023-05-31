function c3dobj = f_add_dom3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_dom3d','id_dom2d','id_layer','elem_code',...
           'defined_on'};

% --- default input value
id_mesh3d = [];
id_dom3d = [];
id_dom2d = [];
id_layer = [];
elem_code = [];
defined_on = 'elem'; % 'face', 'interface', 'bound_face', 'edge', 'bound_edge'

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_dom3d)
    error([mfilename ' : #id_dom3d must be given !']);
end

%--------------------------------------------------------------------------
switch c3dobj.mesh3d.(id_mesh3d).mesher
    case 'c3d_hexamesh'
        if strcmpi(defined_on,'elem')
            [id_elem, elem_code] = f_c3d_hexamesh_find_elem3d(c3dobj, ...
                'id_mesh3d',id_mesh3d,'id_dom3d',id_dom3d,'id_dom2d',id_dom2d,...
                'id_layer',id_layer,'elem_code',elem_code);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = defined_on;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem = id_elem;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).elem_code = elem_code;
        end
        if strcmpi(defined_on,'face')
            [id_elem, elem_code] = f_c3d_hexamesh_find_elem3d(c3dobj, ...
                'id_mesh3d',id_mesh3d,'id_dom3d',id_dom3d,'id_dom2d',id_dom2d,...
                'id_layer',id_layer,'elem_code',elem_code);
            %--------------------------------------------------------------
            % output
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).defined_on = defined_on;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem = id_elem;
            c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).elem_code = elem_code;
        end
    case 'c3d_prismmesh'
    case 'gmsh'
end


