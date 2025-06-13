%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

function lid_node = f_findnode(node,args)
arguments
    node
    args.condition
    args.tolerance = 1e-9
end
%--------------------------------------------------------------------------
cut_equation = f_cut_equation(args.condition);
tol = args.tolerance;
eqcond = cut_equation.eqcond;
neqcond = cut_equation.neqcond;
%--------------------------------------------------------------------------
nbEqcond = length(eqcond);
%--------------------------------------------------------------------------
nb_node = size(node,2);
x = node(1,:);
y = node(2,:);
z = node(3,:);
%--------------------------------------------------------------------------
checksum = [];
neqNode  = [];
%--------------------------------------------------------------------------
if length(neqcond) > 1                     % 1 & something else
    eval(['checksum = (' neqcond ');']);
    neqNode = find(checksum);
else
    neqNode = 1:nb_node;
end
%--------------------------------------------------------------------------
for i = 1:nbEqcond
    eqc = eqcond{i};
    isep = strfind(eqc,'==');
    eqcond_L = eqc(1:isep-1);
    eqcond_R = eqc(isep+2:end);
    % == with tolerance
    eqc = [eqcond_L '<=' eqcond_R '+' num2str(tol) ' & ' ...
           eqcond_L '>=' eqcond_R '-' num2str(tol)];
    eval(['checksum = (' eqc ');']);
    eqNode{i} = find(checksum);
end
%--------------------------------------------------------------------------
eNode = neqNode;
for i = 1:nbEqcond
    eNode = intersect(eNode,eqNode{i});
end
eNode(eNode == 0) = [];
%--------------------------------------------------------------------------
lid_node = unique(eNode);
%--------------------------------------------------------------------------