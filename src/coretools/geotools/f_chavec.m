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
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','edge','face'};

% --- default input value
if size(elem,1) == 2
    elem_type = 'edge';
elseif size(elem,1) > 2
    elem_type = 'face';
end

% --- check and update input
if nargin > 2
    if any(strcmpi(arglist,varargin{1}))
        elem_type = varargin{1};
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
dim = size(node,1);
chavec = zeros(dim,size(elem,2));

switch elem_type
    case 'edge'
        chavec = node(:,elem(2,:)) - node(:,elem(1,:));
        chavec = f_normalize(chavec);
    case 'face'
        V1 = node(:,elem(2,:)) - node(:,elem(1,:));
        V2 = node(:,elem(3,:)) - node(:,elem(1,:));
        chavec = cross(V1,V2);
        chavec = f_normalize(chavec);
end
%--------------------------------------------------------------------------
end