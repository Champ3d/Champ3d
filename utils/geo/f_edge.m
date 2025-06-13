function edge = f_edge(elem,varargin)
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
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
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
e = sort(e, 2);
%--------------------------------------------------------------------------
edge = reshape(permute(e,[2 1 3]), nbNo_inEd, []);
edge = f_unique(edge);
%--------------------------------------------------------------------------
end