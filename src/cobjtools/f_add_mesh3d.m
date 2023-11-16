function c3dobj = f_add_mesh3d(c3dobj,varargin)
% F_ADD_MESH3D ...
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','mesher','id_mesh2d','id_mesh1d','id_layer', ...
           'centering', 'origin_coordinates'};

% --- default input value
mesher    = []; % 'c3d_hexamesh', 'c3d_prismmesh', 'gmsh', 'datfile'
id_mesh3d = []; 
id_mesh2d = [];
id_mesh1d = [];
id_layer  = [];
centering = 0;
origin_coordinates = [0, 0];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(mesher)
    error([mfilename ' : #mesher must be given !']);
end
if isempty(id_mesh3d)
    error([mfilename ' : #id_mesh3d must be given !']);
end
%--------------------------------------------------------------------------
switch mesher
    case 'c3d_hexamesh'
        c3dobj = f_c3d_hexamesh(c3dobj,varargin{:});
    case {'c3d_prismmesh','c3d_prismesh'}
        c3dobj = f_c3d_prismmesh(c3dobj,varargin{:});
    case 'gmsh'
        % TODO
    case {'c3d_mixedmesh','c3d_mixedhexaprismmesh','c3d_mixedhexaprism'}
        % TODO
end
%--------------------------------------------------------------------------
c3dobj.mesh3d.(id_mesh3d).origin_coordinates = origin_coordinates;
c3dobj.mesh3d.(id_mesh3d).dom3d.all_domain.defined_on = {'3d','elem'};
c3dobj.mesh3d.(id_mesh3d).dom3d.all_domain.id_elem = 1:c3dobj.mesh3d.(id_mesh3d).nb_elem;
c3dobj.mesh3d.(id_mesh3d).dom3d.all_domain.elem_code = unique(c3dobj.mesh3d.(id_mesh3d).elem_code);
% --- status
c3dobj.mesh3d.(id_mesh3d).to_be_rebuilt = 1;
%--------------------------------------------------------------------------
f_fprintf(0,'Add #mesh3d',...
          1,id_mesh3d,...
          0,'\n');




