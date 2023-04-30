function geo = f_add_mesh3d(geo,varargin)
% F_ADD_MESH3D ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','mesher','id_mesh2d','id_layer'};

% --- default input value
mesher    = []; % 'champ3d_hexa', 'champ3d_prism', 'gmsh', 'datfile'
id_mesh3d = []; 
id_mesh2d = [];
id_layer  = [];

% --- check and update input
for i = 1:(nargin-1)/2
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
    case 'champ3d_hexa'
        %------------------------------------------------------------------
        geo = f_champ3d_hexa(geo,varargin{:});
        %mesh = f_intkit3d(mesh);
        %------------------------------------------------------------------
    case 'champ3d_prism'
        % TODO
        %mesh = f_prism2dto3d(dom2d,layer);
        %mesh = f_intkit3d(mesh);
    case 'gmsh'
        % TODO
end








