%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function f_patch(node,elem,args)
arguments
    node
    elem
    args.defined_on {mustBeMember(args.defined_on,{'face','elem'})} = 'face'
    args.scalar_field = []
    args.face_color = 'c'
    args.edge_color = 'none'
end
%--------------------------------------------------------------------------
defined_on = args.defined_on;
edge_color = args.edge_color;
face_color = args.face_color;
scalar_field = f_tocolv(args.scalar_field);
%--------------------------------------------------------------------------
if isreal(scalar_field)
    fs{1} = scalar_field;
else
    fs{1} = real(scalar_field);
    fs{2} = imag(scalar_field);
    fs{3} = sqrt(fs{1}.^2 + fs{2}.^2);
end
%--------------------------------------------------------------------------
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
    % ---
    if any(f_strcmpi(defined_on,{'face'}))
        %------------------------------------------------------------------
        clear msh;
        %------------------------------------------------------------------
        msh.Vertices  = node.';
        msh.FaceColor = face_color;
        msh.EdgeColor = edge_color;
        %------------------------------------------------------------------
        
        %------------------------------------------------------------------
        if numel(fs{i}) == size(elem,2)
            % ---
            maxfs = max(fs{i});
            minfs = min(fs{i});
            % ---
            id_tria = find(elem(4,:) == 0);
            id_quad = setdiff(1:size(elem,2),id_tria);
            % ---
            if ~isempty(id_tria)
                msh.Faces = (elem(1:3,id_tria)).';
                msh.FaceVertexCData = full(fs{i}(id_tria));
                msh.FaceColor = 'flat';
                patch(msh); hold on
            end
            % ---
            if ~isempty(id_quad)
                msh.Faces = (elem(1:4,id_quad)).';
                msh.FaceVertexCData = full(fs{i}(id_quad));
                msh.FaceColor = 'flat';
                patch(msh); hold on
            end
        elseif numel(fs{i}) == size(node,2)
            % ---
            id_node = f_uniquenode(elem);
            maxfs = max(fs{i}(id_node));
            minfs = min(fs{i}(id_node));
            % ---
            msh.Faces = elem.';
            msh.FaceVertexCData = full(fs{i});
            msh.FaceColor = 'interp';
            patch(msh); hold on
        end
        % ---
        if maxfs > minfs
            caxis([minfs maxfs]);
        end
        axis equal; axis tight; f_colormap;
        %------------------------------------------------------------------
        f_chlogo;
    else
        %------------------------------------------------------------------
        face = f_boundface(elem,node,'elem_type',elem_type);
        f_patch(node,face,'defined_on','face','edge_color',edge_color,...
            'face_color',face_color,'scalar_field',scalar_field);
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------

