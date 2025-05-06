function f_view_mesh2d(node,elem,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','face_color','edge_color','alpha_value'};

% --- default input value
elem_type   = '';
edge_color  = 'k'; % [0.7 0.7 0.7] --> gray
face_color  = 'c';
alpha_value = 0.9;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
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
        msh.Faces = elem.';
end
%--------------------------------------------------------------------------
msh.FaceColor = face_color;
msh.EdgeColor = edge_color;
patch(msh);
xlabel('x (m)'); ylabel('y (m)');
axis equal; alpha(alpha_value); hold on






