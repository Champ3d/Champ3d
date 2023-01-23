function bcen = f_barrycenter(node,elem,varargin)
% F_BARRYCENTER computes the coordinates of the barrycenters
% of each element (in #elem) given the nodes (#node)
%--------------------------------------------------------------------------
% FIXED INPUT
% node : nD x nb_nodes
% elem : nb_nodes_per_elem x nb_elem
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'dim' : dimension (2, 3, ...)
% 'nb_vertices' : nb_vertices_per_elem
%--------------------------------------------------------------------------
% OUTPUT
% bcen : nD x nb_elem
%--------------------------------------------------------------------------
% EXAMPLE
% bcen = F_BARRYCENTER(node,elem,'dim',3,'nb_vertices',3);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','dim','nb_vertices'};

% --- default input value
dim = size(node,1);
nb_vertices = size(elem,1);

% --- check and update input
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
elem  = elem(1:nb_vertices,:);
[xelem,id_elem] = f_filterface(elem);
%--------------------------------------------------------------------------
len  = size(xelem,2);
bcen = zeros(dim,len);
if size(node,1) < dim
    for i = 1:dim-size(node,1)
        node = [node; zeros(1,len)];
    end
end

for k = 1:length(xelem)
    for i = 1:dim
        lenx = length(id_elem{k});
        s = zeros(1,lenx);
        nb_vertices = size(xelem{k},1);
        for j = 1:nb_vertices
            s = s + node(i,xelem{k}(j,:));
        end
        bcen(i,id_elem{k}) = s./nb_vertices;
    end
end
%--------------------------------------------------------------------------
end