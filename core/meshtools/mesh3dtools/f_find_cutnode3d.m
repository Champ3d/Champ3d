function id_node = f_find_cutnode3d(node,elem,varargin)
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
arglist = {'node','elem','cut_equation','elem_type','tol','defined_on'};

% --- default input value
cut_equation = '';
elem_type = [];
tol = 1e-9; % tolerance
defined_on = 'elem';
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
cut_equation = f_cut_equation(cut_equation,varargin);
%--------------------------------------------------------------------------
eqcond = cut_equation.eqcond;
neqcond = cut_equation.neqcond;
%--------------------------------------------------------------------------
nbEqcond = length(eqcond);
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(elem,'defined_on',defined_on);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
%--------------------------------------------------------------------------
IDNode = [];
for i = 1:nbNo_inEl
    IDNode = [IDNode elem(i,:)];
end
x = node(1,IDNode);
y = node(2,IDNode);
z = node(3,IDNode);
%--------------------------------------------------------------------------
checksum = [];
neqNode  = [];
%--------------------------------------------------------------------------
if length(neqcond) > 1                      % 1 & something else
    eval(['checksum = (' neqcond ');']);
    neqNode = find(checksum);
else
    neqNode = 1:length(IDNode);
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
id_node = unique(IDNode(eNode));
%--------------------------------------------------------------------------





















