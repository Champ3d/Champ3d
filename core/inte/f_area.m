function area = f_area(node,face,args)
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
    face
    args.cdetJ = []
    args.elem_type {mustBeMember(args.elem_type,{'tri','triangle','quad','tet','tetra','prism','hex','hexa'})}
end

% --- 
cdetJ = args.cdetJ;
% --- default ouput value
area = zeros(1,size(face,2));
%--------------------------------------------------------------------------
if ~isempty(cdetJ)
    % ---
    if isfield(args,'elem_type')
        elem_type = args.elem_type;
    end
    if isempty(elem_type)
        elem_type = f_elemtype(face,'defined_on','face');
    end
    % ---
    refelem = f_connexion(elem_type);
    cWeigh = refelem.cWeigh;
    % ---
    area = cdetJ{1} .* cWeigh;
    % ---
    return
end
%--------------------------------------------------------------------------
[grface,lid_face,face_elem_type] = f_filterface(face);
%--------------------------------------------------------------------------
for i = 1:length(grface)
    % ---
    elem_type = face_elem_type{i};
    % ---
    if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
        face = grface{i};
        % ---
        flat_node = [];
        if size(node,1) == 3
            [flat_node, ~] = f_flatface(node,face);
        end
        % ---
        refelem = f_refelem(elem_type);
        cU  = refelem.cU;
        cV  = refelem.cV;
        cWeigh = refelem.cWeigh;
        %------------------------------------------------------------------
        [S, ~] = f_jacobien(node,face,'elem_type',elem_type,...
                            'u',cU,'v',cV,'flat_node',flat_node);
        %------------------------------------------------------------------
        S = S{1} .* cWeigh;
        %------------------------------------------------------------------
        area(lid_face{i}) = S;
        %------------------------------------------------------------------
    end
end


