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
    args.face_color = []
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
end
%--------------------------------------------------------------------------
if ~isempty(fs)
    face_color = 'flat';
end
%--------------------------------------------------------------------------
for i = 1:length(fs)
    % ---
    if length(fs) == 2
        subplot(120 + i);
        if i == 1
            title('Real part');
        else
            title('Imag part');
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
        id_tria = find(elem(4,:) == 0);
        id_quad = setdiff(1:size(elem,2),id_tria);
        % ---
        if ~isempty(id_tria)
            msh.Faces = (elem(1:3,id_tria)).';
            msh.FaceVertexCData = full(fs{i}(itria));
            patch(msh); hold on
        end
        % ---
        if ~isempty(id_quad)
            msh.Faces = (elem(1:4,id_quad)).';
            msh.FaceVertexCData = full(fs{i}(id_quad));
            patch(msh); hold on
        end
        % ---
        axis equal; axis tight; f_colormap; hold on
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

