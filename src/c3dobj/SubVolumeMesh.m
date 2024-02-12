%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SubVolumeMesh < Mesh

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
        function obj = SubVolumeMesh(args)
            arguments
                args.info = 'sub_surface_mesh';
                args.parent_mesh MeshType
                args.id_elem
            end
            % ---
            obj.info = args.info;
            obj.parent_mesh = args.parent_mesh;
            obj.id_elem = args.id_elem;
        end
    end

    % --- Methods
    methods
        function 
    end

end



