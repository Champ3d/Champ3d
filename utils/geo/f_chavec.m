function chavec = f_chavec(node,elem,varargin)
% F_CHAVEC returns the characteristic vector of the elements
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% elem : nb_nodes_per_elem x nb_elem
%        elem should be verified with f_sortori
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% elem type : 'edge', 'face'
%--------------------------------------------------------------------------
% OUTPUT
% chavec : nD x nb_elem
%--------------------------------------------------------------------------
% EXAMPLE
% chavec = F_CHAVEC(node,elem,'edge');
%   --> tangent vector of edge element
% chavec = F_CHAVEC(node,elem,'face');
%   --> normal vector of face element
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
arglist = {'defined_on'};

% --- default input value
if size(elem,1) == 2
    defined_on = 'edge';
elseif size(elem,1) > 2
    defined_on = 'face';
end

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
switch defined_on
    case 'edge'
        chavec = node(:,elem(2,:)) - node(:,elem(1,:));
        chavec = f_normalize(chavec);
    case 'face'
        [dim,lnode] = size(node);
        if dim == 2
            node = [node; zeros(1,lnode)];
        elseif dim > 3
            chavec = [];
            return
        end
        V1 = node(:,elem(2,:)) - node(:,elem(1,:));
        V2 = node(:,elem(3,:)) - node(:,elem(1,:));
        chavec = cross(V1,V2);
        chavec = f_normalize(chavec);
end
%--------------------------------------------------------------------------
end