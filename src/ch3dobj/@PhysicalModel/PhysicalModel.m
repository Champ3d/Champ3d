%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalModel < Xhandle
    properties
        info 
        mesh1d struct = []
        mesh2d struct = []
        mesh3d struct = []
        emmodel struct = []
        thmodel struct = []
        memodel struct = []
    end

    % --- Constructors
    methods
        function obj = PhysicalModel(args)
            arguments
                args.info = 'no_info';
            end
            % ---
            obj.info = args.info;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function obj = add_mesh1d(obj,args)
            arguments
                obj
                % ---
                args.id char
                args.len {mustBeNumeric}
                args.dtype = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % ---
            if obj.is_available(args,{'len','dtype','dnum','flog'})
                line = Mesh1d(obj.tmp.args{:});
                obj.mesh1d.(args.id) = line;
            end
        end
        % -----------------------------------------------------------------
        function obj = add_mesh2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d_collection
                args.id_xline = []
                args.id_yline = []
                % ---
                args.mesh_file = []
            end
            % ---
            if obj.is_available(args,'mesh_file')
                msh = TriMeshFromFemm(obj.tmp.args{:});
                obj.mesh2d.(args.id) = msh;
            elseif obj.is_available('id_mesh1d','id_xline','id_yline')
                msh = QuadMeshFrom1d(obj.tmp.args{:});
                obj.mesh2d.(args.id) = msh;
            end
        end
        % -----------------------------------------------------------------
        function obj = add_mesh3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d_collection
                args.id_xline = []
                args.id_yline = []
                % ---
                args.mesh_file = []
            end
            % ---
            if obj.is_available(args,'mesh_file')
                msh = TriMeshFromFemm(obj.tmp.args{:});
                obj.mesh2d.(args.id) = msh;
            elseif obj.is_available('id_mesh1d','id_xline','id_yline')
                msh = QuadMeshFrom1d(obj.tmp.args{:});
                obj.mesh2d.(args.id) = msh;
            end
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end