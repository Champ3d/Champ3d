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
    args.elem_type char = []
    args.tol = 1e-9
    args.defined_on char = []
end

% --- default input value
condition = args.condition;
elem_type = args.elem_type;
% ---
if isempty(args.defined_on)
    defined_on = 'elem';
end

%--------------------------------------------------------------------------
condition = f_cut_equation(condition,varargin);
%--------------------------------------------------------------------------
eqcond = condition.eqcond;
neqcond = condition.neqcond;
%--------------------------------------------------------------------------
nbEqcond = length(eqcond);
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(elem,'defined_on',defined_on);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbElem = size(elem,2);
%----- barrycenter
x = mean(reshape(node(1,elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
y = mean(reshape(node(2,elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
if size(node,1) >= 3
    z = mean(reshape(node(3,elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
end
% ---
if length(neqcond) > 1                      % 1 & something else
    eval(['checksum = (' neqcond ');']);
    id_elem = find(checksum >= 1); 
else
    id_elem = 1:nbElem;
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
    id_elem = intersect(id_elem,iElemEqcond{i});
end
%--------------------------------------------------------------------------
id_elem = unique(id_elem);
%--------------------------------------------------------------------------