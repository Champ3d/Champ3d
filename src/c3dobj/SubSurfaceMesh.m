%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SubSurfaceMesh < Mesh

    % --- Properties
    properties
        % --- sub
        parent_mesh
        gid_node
        gid_elem
        gid_edge
        gid_face
        flat_node
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Hidden Properties
    properties (Hidden = true)
        defined_with
    end

    % --- Constructors
    methods
        function obj = SubSurfaceMesh(args)
            arguments
                args.info = 'sub_surface_mesh';
                args.parent_mesh MeshType
                args.elem_type
                args.node = []
                args.elem = []
            end
            % ---
            obj.info = args.info;
            obj.parent_mesh = args.parent_mesh;
            obj.elem_type  = args.elem_type;
            obj.node = args.node;
            obj.elem = args.elem;
        end
    end

    % --- Methods
    methods
        
    end

end



