function f_view_face(node,face,varargin)
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
edge_color  = 'none';
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
is3dface = 0;
if size(node,1) == 3
    is3dface = 1;
end
%--------------------------------------------------------------------------
switch elem_type
    case {'tri', 'triangle'}
        msh.Faces = face(1:3,:).';
    case {'quad'}
        msh.Faces = face(1:4,:).';
    otherwise
        msh.Faces = face.';
end
%--------------------------------------------------------------------------
msh.FaceColor = face_color;
msh.EdgeColor = edge_color; % [0.7 0.7 0.7] --> gray
patch(msh);
xlabel('x (m)'); ylabel('y (m)'); if is3dface, zlabel('z (m)'); end
axis equal; axis tight; alpha(alpha_value); hold on
%--------------------------------------------------------------------------
c3name = '$\overrightarrow{champ}{3d}$';
texpos = get(gca, 'OuterPosition');
hold on;
text(texpos(1),texpos(2)+1.05, ...
     c3name, ...
     'FontSize',10, ...
     'FontWeight','bold',...
     'Color','blue', ...
     'Interpreter','latex',...
     'Units','normalized', ...
     'VerticalAlignment', 'baseline', ...
     'HorizontalAlignment', 'right');





