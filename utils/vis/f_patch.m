%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

function f_patch(args)
arguments
    args.node = []
    args.face = []
    args.elem = []
    args.node_field = []
    args.face_field = []
    args.elem_field = []
    args.face_color = 'c'
    args.edge_color = 'none'
end
%--------------------------------------------------------------------------
if isempty(args.node)
    error('#node must be given !');
else
    node = args.node;
end
% ---
dim = size(node,1);
%--------------------------------------------------------------------------
mesh_defined_on_face = 0;
mesh_defined_on_elem = 0;
if isempty(args.face) && isempty(args.elem)
    error('#face or #elem must be given !');
elseif ~isempty(args.face)
    mesh_defined_on_face = 1;
    face = args.face;
elseif ~isempty(args.elem)
    mesh_defined_on_elem = 1;
    elem = args.elem;
end
%--------------------------------------------------------------------------
edge_color = args.edge_color;
face_color = args.face_color;
%--------------------------------------------------------------------------
field_defined_on_node = 0;
field_defined_on_face = 0;
field_defined_on_elem = 0;
if ~isempty(args.node_field)
    field_defined_on_node = 1;
    scalar_field = f_tocolv(args.node_field);
elseif ~isempty(args.face_field)
    field_defined_on_face = 1;
    scalar_field = f_tocolv(args.face_field);
elseif ~isempty(args.elem_field)
    field_defined_on_elem = 1;
    scalar_field = f_tocolv(args.elem_field);
end
%--------------------------------------------------------------------------
switch dim
    case 2
        % ---
        if mesh_defined_on_elem && field_defined_on_elem
            elem_type = f_elemtype(elem);
            [face,id_elem_of_face] = f_boundface(elem,node,'elem_type',elem_type);
            f_patch('node',node,'face',face,...
                'face_field',scalar_field(id_elem_of_face),...
                'edge_color',edge_color,'face_color',face_color);
            % ---
            view(2);
            % ---
        elseif mesh_defined_on_elem && field_defined_on_node
            f_patch('node',node,'face',face,...
                'node_field',scalar_field,...
                'edge_color',edge_color,'face_color',face_color);
            % ---
            view(2);
            % ---
        elseif mesh_defined_on_elem && field_defined_on_face
            text(0,0,0,'cannot plot !');
        elseif mesh_defined_on_face
            text(0,0,0,'cannot plot !');
        end
        % ---
    case 3
        % ---
        if mesh_defined_on_elem && field_defined_on_elem
            elem_type = f_elemtype(elem);
            [face,id_elem_of_face] = f_boundface(elem,node,'elem_type',elem_type);
            f_patch('node',node,'face',face,...
                'face_field',scalar_field(id_elem_of_face),...
                'edge_color',edge_color,'face_color',face_color);
            % ---
            view(3);
            % ---
        elseif mesh_defined_on_elem && field_defined_on_node
            elem_type = f_elemtype(elem);
            face = f_boundface(elem,node,'elem_type',elem_type);
            f_patch('node',node,'face',face,...
                'node_field',scalar_field,...
                'edge_color',edge_color,'face_color',face_color);
            % ---
            view(3);
            % ---
        elseif mesh_defined_on_elem && field_defined_on_face
            text(0,0,0,'cannot plot !');
        elseif mesh_defined_on_face && field_defined_on_elem
            text(0,0,0,'cannot plot !');
        end
        % ---
end
%--------------------------------------------------------------------------
if isreal(scalar_field)
    fs{1} = scalar_field;
else
    fs{1} = real(scalar_field);
    fs{2} = imag(scalar_field);
    fs{3} = sqrt(fs{1}.^2 + fs{2}.^2);
end
%--------------------------------------------------------------------------
maxfs = 0;
minfs = 0;
for i = 1:length(fs)
    % ---
    if length(fs) >= 2
        subplot(130 + i);
        if i == 1
            title('Real part');
        elseif i == 2
            title('Imag part');
        elseif i == 3
            title('Magnitude');
        end
    end
    %------------------------------------------------------------------
    clear msh;
    %------------------------------------------------------------------
    msh.Vertices  = node.';
    msh.FaceColor = face_color;
    msh.EdgeColor = edge_color;
    %------------------------------------------------------------------
    if field_defined_on_face
        % ---
        maxfs = max(fs{i});
        minfs = min(fs{i});
        % ---
        nb_face = size(face,2);
        if size(face,1) == 4
            id_tria = find(face(4,:) == 0);
        elseif size(face,1) == 3
            id_tria = 1:nb_face;
        end
        % ---
        id_quad = setdiff(1:nb_face,id_tria);
        % ---
        if ~isempty(id_tria)
            msh.Faces = (face(1:3,id_tria)).';
            msh.FaceVertexCData = full(fs{i}(id_tria));
            msh.FaceColor = 'flat'; % !!! the difference
            patch(msh); hold on
        end
        % ---
        if ~isempty(id_quad)
            msh.Faces = (face(1:4,id_quad)).';
            msh.FaceVertexCData = full(fs{i}(id_quad));
            msh.FaceColor = 'flat'; % !!! the difference
            patch(msh); hold on
        end
        % ---
        if maxfs > minfs
            caxis([minfs maxfs]);
        end
        % ---
        h = colorbar;
        h.Label.String = 'Enter Unit';
        axis equal; axis tight; f_colormap; view(3);
        % ---
        f_chlogo;
        % ---
    elseif field_defined_on_node
        % ---
        id_node = f_uniquenode(face);
        maxfs = max(fs{i}(id_node));
        minfs = min(fs{i}(id_node));
        % ---
        msh.Faces = face.';
        msh.FaceVertexCData = full(fs{i});
        msh.FaceColor = 'interp'; % !!! the difference
        patch(msh); hold on
        % ---
        if maxfs > minfs
            caxis([minfs maxfs]);
        end
        % ---
        h = colorbar;
        h.Label.String = 'Enter Unit';
        axis equal; axis tight; f_colormap; view(3);
        % ---
        f_chlogo;
        % ---
    end
end
