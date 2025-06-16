function [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = f_edgeinelem(elem,edge_list,varargin)
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
arglist = {'elem_type','defined_on'};

% --- default input value
elem_type = [];
defined_on = 'elem';

% --- default output value
id_edge_in_elem = [];
sign_edge_in_elem = [];
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(f_strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(elem,'defined_on',defined_on);
end
%--------------------------------------------------------------------------
refelem = f_refelem(elem_type);
nbNo_inEd = refelem.nbNo_inEd;
nbEd_inEl = refelem.nbEd_inEl;
EdNo_inEl = refelem.EdNo_inEl;
%--------------------------------------------------------------------------
nbElem = size(elem,2);
%--------------------------------------------------------------------------
e = reshape([elem(EdNo_inEl(:,1),:); elem(EdNo_inEl(:,2),:)], ...
             nbEd_inEl, nbNo_inEd, nbElem);
% ---
ori_edge_in_elem = squeeze(sign(diff(e, 1, 2))); % with unsorted e !
if any(strcmpi(elem_type,{'tri','quad','triangle'}))
    sign_edge_in_elem = ori_edge_in_elem .* refelem.siEd_inEl;
elseif any(strcmpi(elem_type,{'hex','hexa','prism','tet','tetra'}))
    sign_edge_in_elem = 0;
end
%--------------------------------------------------------------------------
if ~isempty(edge_list)
    e = sort(e, 2);
    id_edge_in_elem = f_findvecnd(e,edge_list,'position',2);
end
%--------------------------------------------------------------------------
end