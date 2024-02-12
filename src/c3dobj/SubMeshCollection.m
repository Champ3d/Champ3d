%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SubMeshCollection < Xhandle

    % --- Properties
    properties
        info = []
        data = []
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = SubMeshCollection(args)
            arguments
                args.info = 'no_info'
                args.data = []
            end
            % ---
            obj.info = args.info;
            obj.data = args.data;
        end
    end

    % --- Methods
    methods
        function obj = add_submesh(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh Mesh
            end
            % ---
            obj.data.(args.id) = mesh;
        end
        % ---
    end
end
