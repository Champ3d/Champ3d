function chavec = f_chavec(node,elem,varargin)
% F_CHAVEC returns the characteristic vector of the elements
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% elem : nb_nodes_per_elem x nb_elem
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
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
dim = size(node,1);
chavec = zeros(dim,size(elem,2));

switch elem_type
    case 'edge'
        for i = 1:dim
            chavec(i,:) = node(i,elem(2,:)) - node(i,elem(1,:));
        end
        chavec = f_normalize(chavec);
    case 'face'
        V1 = zeros(3,size(elem,2));
        V2 = zeros(3,size(elem,2));
        for i = 1:dim
            V1(i,:) = node(i,elem(2,:)) - node(i,elem(1,:));
            V2(i,:) = node(i,elem(3,:)) - node(i,elem(1,:));
        end
        chavec = cross(V1,V2);
        chavec = f_normalize(chavec);
end
%--------------------------------------------------------------------------
end