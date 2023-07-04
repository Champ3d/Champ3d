function id_node = f_find_cutnode3d(node,elem,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','cut_equation','elem_type','tol'};

% --- default input value
cut_equation = '';
elem_type = 'hex';
tol = 1e-9; % tolerance

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
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





















