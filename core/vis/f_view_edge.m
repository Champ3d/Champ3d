function f_view_edge(node,edge,varargin)
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
arglist = {'edge_color','edge_width'};

% --- default input value
edge_color = 'b';
edge_width = 1;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
for3d = 0;
if size(node,1) == 3
    for3d = 1;
end
%--------------------------------------------------------------------------
x1 = node(1,edge(1,:));
x2 = node(1,edge(2,:));
y1 = node(2,edge(1,:));
y2 = node(2,edge(2,:));
x = [x1; x2];
y = [y1; y2];
if for3d
    z1 = node(3,edge(1,:));
    z2 = node(3,edge(2,:));
    z = [z1; z2];
end
%--------------------------------------------------------------------------
if for3d
    line(x,y,z,'color',edge_color,'linewidth',edge_width); view(3)
else
    line(x,y,'color',edge_color,'linewidth',edge_width);
end
%--------------------------------------------------------------------------
















