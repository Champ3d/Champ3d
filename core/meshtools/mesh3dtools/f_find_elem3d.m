function id_elem = f_find_elem3d(node,elem,varargin)
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
arglist = {'node','elem','dom3d_equation','elem_type','tol','defined_on'};

% --- default input value
dom3d_equation = '';
elem_type = [];
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
dom3d_equation = f_cut_equation(dom3d_equation,varargin);
%--------------------------------------------------------------------------
eqcond = dom3d_equation.eqcond;
neqcond = dom3d_equation.neqcond;
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
z = mean(reshape(node(3,elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
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