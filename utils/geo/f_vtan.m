function vtan = f_vtan(node,elem,varargin)
% F_VTAN returns the tangent vectors of elem
%--------------------------------------------------------------------------
% vtan = F_VTAN(node,elem)
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

if mod(nargin,2) ~= 0 
    error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : #node, #elem, #dim, #nb_vertices !']);
end

for i = 1:length(varargin)/2
    eval([varargin{2*i-1} '= varargin{2*i};']);
end

if ~exist('node','var') | ~exist('elem','var') | ~exist('dim','var')
    error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : #node, #elem, #dim, #nb_vertices !']);
end
if ~exist('nb_vertices','var')
    nb_vertices = 2;
end
if ~exist('normalize','var')
    normalize = 1;
end

%--------------------------------------------------------------------------
len = size(elem,2);
vtan = zeros(dim,len);
if size(node,1) < dim
    for i = 1:dim-size(node,1)
        node = [node; zeros(1,len)];
    end
end
switch nb_vertices
    case 2
        mag = zeros(1,len);
        for i = 1:dim
            vtan(i,:) = node(i,elem(2,:)) - node(i,elem(1,:));
            mag = mag + vtan(i,:).^2;
        end
        mag = sqrt(mag);
        if normalize == 1 | strcmpi(normalize,'yes')
            for i = 1:dim
                vtan(i,:) = vtan(i,:)./mag;
            end
        end
    otherwise
end
%--------------------------------------------------------------------------
end