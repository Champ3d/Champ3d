function area = f_area(node,face,args)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    node
    face
    args.cdetJ = []
    args.elem_type {mustBeMember(args.elem_type,{'','tri','triangle','quad','tet','tetra','prism','hex','hexa'})} = ''
end

% --- 
cdetJ = args.cdetJ;
elem_type = args.elem_type;
% --- default ouput value
area = zeros(1,size(face,2));
%--------------------------------------------------------------------------
if isempty(elem_type)
    elem_type = f_elemtype(face,'defined_on','face');
end
%--------------------------------------------------------------------------
if ~isempty(cdetJ)
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
        [S, ~] = f_jacobien(node,elem,'elem_type',elem_type,...
                            'u',cU,'v',cV,'flat_node',flat_node);
        %------------------------------------------------------------------
        S = S{1} .* cWeigh;
        %------------------------------------------------------------------
        area(lid_face{i}) = S;
        %------------------------------------------------------------------
    end
end


