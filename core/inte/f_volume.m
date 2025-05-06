function vol = f_volume(node,elem,args)
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

arguments
    node
    elem
    args.cdetJ = []
    args.elem_type {mustBeMember(args.elem_type,{'','tri','triangle','quad','tet','tetra','prism','hex','hexa'})} = ''
end

% --- 
cdetJ = args.cdetJ;
elem_type = args.elem_type;
% --- default ouput value
vol = [];
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
if ~isempty(cdetJ)
    refelem = f_refelem(elem_type);
    cWeigh = refelem.cWeigh;
    % ---
    vol = cdetJ{1} .* cWeigh;
    % ---
    return
end
%--------------------------------------------------------------------------
refelem = f_refelem(elem_type);
cU  = refelem.cU;
cV  = refelem.cV;
if any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    cW = refelem.cW;
else
    cW = [];
end
cWeigh = refelem.cWeigh;
%--------------------------------------------------------------------------
[vol, ~] = f_jacobien(node,elem,'elem_type',elem_type,...
                      'u',cU,'v',cV,'w',cW);
%--------------------------------------------------------------------------
vol = vol{1} .* cWeigh;
%--------------------------------------------------------------------------



