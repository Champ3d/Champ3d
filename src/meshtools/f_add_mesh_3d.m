function design3d = f_add_mesh_3d(design3d,varargin)
% F_ADD_MESH_3D
% f_make_mesh3D('mesher','prism2dto3d','dom2d',dom2d,'layer',layer)
%
% 'mesher' : 
%    'prism2dto3d', '3dmatlab', 'gmsh', '2d3dfemm'
% for 'prism2dto3d', give:
%    + 'dom2d', 'layer'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','mesher','id_mesh','dom2d','layer'};

% --- default input value
mesher  = [];
dom2d   = [];
layer   = [];
%--------------------------------------------------------------------------
if ~isfield(design3d,'mesh')
    iec = 0;
else
    iec = length(design3d.mesh);
end

% --- default input value
id_mesh = ['mesh' num2str(iec+1)];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No mesh to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
fprintf('Making 3D mesh ... ');
tic
switch lower(mesher)
    case 'prism2dto3d'
        mesh = f_prism2dto3d(dom2d,layer);
        mesh = f_intkit3d(mesh);
        mesh.mesher = 'prism2dto3d';
    case '3dmatlab'
        return
    case 'gmsh'
        return
    case '2d3dfemm'
        mesh = f_prism2dto3d(dom2d,layer);
        mesh = f_intkit3d(mesh);
        mesh.mesher = 'prism2dto3d';
    case 'hexa2dto3d'
        mesh = f_hexa2dto3d(dom2d,layer);
        mesh = f_intkit3d(mesh);
        mesh.mesher = 'hexa2dto3d';
end
fprintf('%.4f s \n',toc);
%--------------------------------------------------------------------------
design3d.mesh(iec+1) = mesh;
%design3d.mesh(iec+1).id_mesh  = id_mesh;
%design3d.mesh(iec+1) = f_addtostruct(mesh,design3d.mesh(iec+1));








