%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

function id_elem = f_find_bounding_elem(node,elem,interior_node)
arguments
    node
    elem
    interior_node
end

dim = size(node,1);

if dim == 2
    V1 = [node(1,elem(1,:)); node(2,elem(1,:))] - [interior_node(1); interior_node(2)];
    V2 = [node(1,elem(2,:)); node(2,elem(2,:))] - [interior_node(1); interior_node(2)];
    V3 = [node(1,elem(3,:)); node(2,elem(3,:))] - [interior_node(1); interior_node(2)];
    a1 = f_vecangle(V1, V2);
    a2 = f_vecangle(V2, V3);
    a3 = f_vecangle(V3, V1);
    a  = a1 + a2 + a3;
    id_elem = find(abs(a) > 179);
    % ---
elseif dim == 3
    % --- XTODO
    id_elem = [];
else
    id_elem = [];
end

end