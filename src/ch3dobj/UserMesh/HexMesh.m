%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef HexMesh < Mesh

    % --- Properties
    properties

    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = HexMesh(args)
            arguments
                args.node = []
                args.elem = []
            end
            % ---
            obj.elem_type = 'hexa';
            obj.node = args.node;
            obj.elem = args.elem;
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'none'
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            if isempty(obj.face)
                obj.build_meshds('get','face');
            end
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            msh.Vertices = obj.node.';
            msh.Faces = f_unique(obj.face(1:4,:)).';
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            patch(msh);
            xlabel('x (m)'); ylabel('y (m)');
            if size(obj.node,1) == 3
                zlabel('z (m)'); 
            end
            axis equal; axis tight; alpha(alpha_); view(3); hold on
            %--------------------------------------------------------------
            f_chlogo;
        end
    end

end



