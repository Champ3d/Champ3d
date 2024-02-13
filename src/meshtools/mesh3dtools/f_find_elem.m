%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function id_elem = f_find_elem(node,elem,args)
arguments
    node
    elem
    args.condition char
    args.tol = 1e-12
end

% --- default input value
condition = args.condition;
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
        eqcond_L = strrep(eqcond{i},'==','<');
        eqcond_R = strrep(eqcond{i},'==','>');
        eval(['iEqcond_L{i} = (' eqcond_L ');']);
        eval(['iEqcond_R{i} = (' eqcond_R ');']);
        checksum_L = sum(iEqcond_L{i});
        checksum_R = sum(iEqcond_R{i});
        checksum   = checksum_L + checksum_R;
        % just need one node touched
        iElemEqcond{i} = find( (checksum_L < nbNo_inEl & checksum_L > 0 & ...
                                checksum_R < nbNo_inEl & checksum_R > 0)  ...
                              |(checksum   < nbNo_inEl)); 
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