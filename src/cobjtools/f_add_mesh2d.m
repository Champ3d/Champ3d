function c3dobj = f_add_mesh2d(c3dobj,varargin)
% F_ADD_MESH2D ...
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
arglist = {'build_from','id_mesh2d','id_mesh1d','flog','id_x','id_y',...
           'centering', 'origin_coordinates', ...
           'mesh_file',...
           'shape2d','hgrad','hmax','box','init','jiggle','jiggleiter','mesherversion'};

% --- default input value
build_from = 'mesh1d'; % 'mesh1d', 'geoquad', 'femm', 'shape2d'
id_mesh2d = [];
id_mesh1d = [];
flog = 1.05; % log factor when making log mesh
id_x = [];
id_y = [];
centering = 0;
origin_coordinates = [0, 0];
mesh_file = [];
shape2d = [];
hgrad = 1.3;
hmax = 1;
box  = 'off';
init = 'off';
jiggle = 'mean';
jiggleiter = 10;
mesherversion = 'R2013a';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~any(strcmpi(build_from,{'mesh1d','geoquad','femm','shape2d'}))
    error([mfilename ' : #build_from should be mesh1d, geoquad, femm or shape2d !']);
end
if any(strcmpi(build_from,{'femm'}))
    if isempty(mesh_file)
        error([mfilename ' : #mesh_file should be given !']);
    end
end
if isempty(id_mesh2d)
    error([mfilename ' : #id_mesh2d must be given !']);
end
%--------------------------------------------------------------------------
if strcmpi(build_from,'mesh1d')
    %----------------------------------------------------------------------
    % --- Output
    c3dobj = f_mesh2dgeo1d(c3dobj,'id_mesh2d',id_mesh2d,'id_mesh1d',id_mesh1d,...
             'flog',flog,'id_x',id_x,'id_y',id_y,...
             'centering',centering,'origin_coordinates',origin_coordinates);
elseif strcmpi(build_from,'femm')
    c3dobj = f_femm_loadmeshfile(c3dobj,'id_mesh2d',id_mesh2d,...
             'mesh_file',mesh_file,...
             'centering',centering,'origin_coordinates',origin_coordinates);
elseif strcmpi(build_from,'shape2d')
    c3dobj = f_pdetool2d(c3dobj,'id_mesh2d',id_mesh2d,...
             'shape2d',shape2d,'hgrad',hgrad,'hmax',hmax,'box',box,'init',init,...
             'jiggle',jiggle,'jiggleiter',jiggleiter,'mesherversion',mesherversion,...
             'centering',centering,'origin_coordinates',origin_coordinates);
elseif strcmpi(build_from,'geoquad')
    % TODO
end
%--------------------------------------------------------------------------
c3dobj.mesh2d.(id_mesh2d).origin_coordinates = origin_coordinates;
c3dobj.mesh2d.(id_mesh2d).dom2d.all_domain.defined_on = {'2d','elem'};
c3dobj.mesh2d.(id_mesh2d).dom2d.all_domain.id_elem = 1:c3dobj.mesh2d.(id_mesh2d).nb_elem;
c3dobj.mesh2d.(id_mesh2d).dom2d.all_domain.elem_code = unique(c3dobj.mesh2d.(id_mesh2d).elem_code);
% --- status
c3dobj.mesh2d.(id_mesh2d).to_be_rebuilt = 1;
%--------------------------------------------------------------------------
% --- Log message
f_fprintf(0,'Add #mesh2d',1,id_mesh2d,0,'\n');








