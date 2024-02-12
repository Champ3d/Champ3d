%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh3dCollection < Xhandle

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
        function obj = Mesh3dCollection(args)
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
        % ---
        function obj = add_from_mesh2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d_collection Mesh1dCollection
                args.mesh2d_collection Mesh2dCollection
                args.id_mesh2d char = []
                args.id_zline = []
            end
            % ---
            
            if isa(args.mesh2d_collection.data.(args.id_mesh2d),'QuadMesh')
                mtype = @HexaMeshFromQuadMesh;
            elseif isa(args.mesh2d_collection.data.(args.id_mesh2d),'TriMesh')
                mtype = @PrismMeshFromTriMesh;
            end
            % ---
            argu = f_to_namedarg(args,'with_out','id');
            msh = mtype(argu{:});
            % ---
            obj.data.(args.id) = msh;
        end
        % ---
        function obj = add_from_femm(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh_file char
            end
            % ---
            msh = TriMeshFromFemm('mesh_file',args.mesh_file);
            % ---
            obj.data.(args.id) = msh;
        end
        % ---
    end
end











