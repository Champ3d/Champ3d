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
           'mesh_file'};

% --- default input value
build_from = 'mesh1d'; % 'mesh1d', 'geoquad', 'femm'
id_mesh2d = [];
id_mesh1d = [];
flog = 1.05; % log factor when making log mesh
id_x = [];
id_y = [];
centering = 0;
origin_coordinates = [0, 0];
mesh_file = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~any(strcmpi(build_from,{'mesh1d','geoquad','femm'}))
    error([mfilename ' : #build_from should be #mesh1d, #geoquad or #femm !']);
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
    c3dobj = f_mesh2dgeo1d(c3dobj,varargin{:});
    % --- Log message
    f_fprintf(0,'Add #mesh2d',1,id_mesh2d,0,'\n');

elseif strcmpi(build_from,'femm')
    c3dobj = f_femm_loadmeshfile(c3dobj,varargin{:});
    % --- Log message
    f_fprintf(0,'Add #mesh2d',1,id_mesh2d,0,'\n');
    
elseif strcmpi(build_from,'geoquad')
    % TODO
end








