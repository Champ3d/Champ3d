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

function id_elem = f_findelem(node,elem,args)
arguments
    node
    elem
    args.condition char = ''
    args.in_box = []
    args.tol = 1e-9
end
%--------------------------------------------------------------------------
condition = args.condition;
in_box    = args.in_box;
%--------------------------------------------------------------------------
id_elem = [];
if isempty(condition) && isempty(in_box)
    return
end
%--------------------------------------------------------------------------
if ~isempty(in_box)
    xmin = in_box.xmin;
    xmax = in_box.xmax;
    ymin = in_box.ymin;
    ymax = in_box.ymax;
    zmin = in_box.zmin;
    zmax = in_box.zmax;
    id_elem = f_findelem(node,elem,...
         'condition',...
        ['x <= ' num2str(xmax) '&&' 'x >= ' num2str(xmin) '&&' ...
         'y <= ' num2str(ymax) '&&' 'y >= ' num2str(ymin) '&&' ...
         'z <= ' num2str(zmax) '&&' 'z >= ' num2str(zmin) ]);
    return
end
%--------------------------------------------------------------------------
condition = f_cut_equation(condition,'tol',args.tol);
%--------------------------------------------------------------------------
eqcond = condition.eqcond;
neqcond = condition.neqcond;
%--------------------------------------------------------------------------
nbEqcond = length(eqcond);
%--------------------------------------------------------------------------
nbelm = size(elem,2);
elemx = [sort(elem,1,"descend"); zeros(1,nbelm)];
%--------------------------------------------------------------------------
ie_gr = {};
el_gr = {};
nb_gr = 1;
ie_gr{1} = [];
% ---
for i = 2 : size(elemx,1)
    if any(elemx(i,:) == 0)
        nb_gr = nb_gr + 1;
        id_ = find(elemx(i,:) == 0);
        ie_gr{nb_gr} = setdiff(id_,ie_gr{nb_gr-1});
        el_gr{nb_gr} = elem(1:i-1,ie_gr{nb_gr});
    end
end
% ---
ie_gr(1) = [];
el_gr(1) = [];
% ---
id_elem = [];
for j = 1:length(el_gr)
    % ---
    elem_ = el_gr{j};
    nbNo_inEl = size(elem_,1);
    nbElem = size(elem_,2);
    %----------------------------------------------------------------------
    %----- barrycenter
    x = mean(reshape(node(1,elem_(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
    y = mean(reshape(node(2,elem_(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
    if size(node,1) >= 3
        z = mean(reshape(node(3,elem_(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
    end
    % ---
    if length(neqcond) > 1                      % 1 & something else
        eval(['checksum = (' neqcond ');']);
        id_elem_ = find(checksum >= 1); 
    else
        id_elem_ = 1:nbElem;
    end
    % ---
    for i = 1:nbEqcond
        eqcond_L = strrep(eqcond{i},'==',['<=+' num2str(args.tol) '+']);
        eqcond_R = strrep(eqcond{i},'==',['>=-' num2str(args.tol) '+']);
        eval(['iEqcond_L{i} = (' eqcond_L ');']);
        eval(['iEqcond_R{i} = (' eqcond_R ');']);
        checksum_L = iEqcond_L{i};
        checksum_R = iEqcond_R{i};
        checksum   = checksum_L + checksum_R;
        % just need one node touched
        iElemEqcond{i} = find(checksum > 1); 
    end
    % ---
    for i = 1:nbEqcond
        id_elem_ = intersect(id_elem_,iElemEqcond{i});
    end
    %----------------------------------------------------------------------
    id_elem_ = unique(id_elem_);
    id_elem = [id_elem ie_gr{j}(id_elem_)];
    %----------------------------------------------------------------------
end