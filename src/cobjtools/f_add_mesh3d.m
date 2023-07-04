function c3dobj = f_add_mesh3d(c3dobj,varargin)
% F_ADD_MESH3D ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','mesher','id_mesh2d','id_mesh1d','id_layer'};

% --- default input value
mesher    = []; % 'c3d_hexamesh', 'c3d_prismmesh', 'gmsh', 'datfile'
id_mesh3d = []; 
id_mesh2d = [];
id_mesh1d = [];
id_layer  = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
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
        %------------------------------------------------------------------
        c3dobj = f_c3d_hexamesh(c3dobj,varargin{:});
        % --- Log message
        fprintf(['Add mesh3d #' id_mesh3d '\n']);
        %------------------------------------------------------------------
    case {'c3d_prismmesh','c3d_prismesh'}
        c3dobj = f_c3d_prismmesh(c3dobj,'id_mesh3d',id_mesh3d,'id_mesh2d',id_mesh2d,...
                                        'id_layer',id_layer);
        % --- Log message
        fprintf(['Add mesh3d #' id_mesh3d '\n']);
    case 'gmsh'
        % TODO
    case {'c3d_mixedmesh','c3d_mixedhexaprismmesh','c3d_mixedhexaprism'}
        % TODO
end








