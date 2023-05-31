function f_view_mesh2d(node,elem,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','face_color','edge_color','alpha_value'};

% --- default input value
elem_type   = '';
edge_color  = 'none';
face_color  = 'w';
alpha_value = 1;
% --- check and update input
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
clear msh;
%--------------------------------------------------------------------------
msh.Vertices = node.';
%--------------------------------------------------------------------------
switch elem_type
    case {'tri', 'triangle'}
        msh.Faces = elem(1:3,:).';
    case {'quad'}
        msh.Faces = elem(1:4,:).';
    otherwise
        msh.Faces = elem(:,:).';
end
%--------------------------------------------------------------------------
msh.FaceColor = face_color;
msh.EdgeColor = edge_color; % [0.7 0.7 0.7] --> gray
patch(msh);
xlabel('x (m)'); ylabel('y (m)');
axis equal; alpha(alpha_value); hold on






