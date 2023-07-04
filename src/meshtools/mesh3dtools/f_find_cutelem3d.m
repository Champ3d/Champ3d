function id_elem = f_find_cutelem3d(node,elem,varargin)
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
nbElem = size(elem,2);
% ---
x = zeros(nbNo_inEl,nbElem);
y = zeros(nbNo_inEl,nbElem);
z = zeros(nbNo_inEl,nbElem);
% ---
for i = 1:nbNo_inEl
    x(i,:) = node(1,elem(i,:));
    y(i,:) = node(2,elem(i,:));
    z(i,:) = node(3,elem(i,:));
end
% ---
if length(neqcond) > 1                      % 1 & something else
    eval(['iNeqcond = (' neqcond ');']);
    eval('checksum = sum(iNeqcond);');
    % just need one node touched
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
