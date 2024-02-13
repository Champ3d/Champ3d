%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SurfaceDom < Xhandle

    % --- Properties
    properties
        parent_mesh Mesh
        gid_face
        build_from
        condition
        defined_on
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = SurfaceDom(args)
            arguments
                % ---
                args.parent_mesh
                args.gid_face = []
                args.build_from = []
                args.condition = []
            end
            % ---
            obj <= args;
        end
    end
end



