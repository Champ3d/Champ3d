%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Ch3Factory < Xhandle
    properties

    end

    % --- Constructors
    methods
        function obj = Ch3Factory()
            obj = obj@Xhandle;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function msh = build_mesh1d(obj,args)
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
            if obj.is_available(args,{'id','len','dtype','dnum','flog'})
                msh = Line1d(obj.tmp.args{:});
            end
        end
        % -----------------------------------------------------------------
        function msh = build_mesh2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh = []
                args.id_xline = []
                args.id_yline = []
                % ---
                args.mesh_file = []
                % ---
                args.node = [];
                args.elem = [];
            end
            % ---
            if obj.is_available(args,'mesh_file')
                msh = TriMeshFromFemm(obj.tmp.args{:});
            elseif obj.is_available(args,{'parent_mesh','id_xline','id_yline'})
                msh = QuadMeshFrom1d(obj.tmp.args{:});
            end
        end
        % -----------------------------------------------------------------
        function msh = build_mesh3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh1d = []
                args.parent_mesh2d = []
                args.id_zline = []
                % ---
                args.mesh_file = []
            end
            % ---
            if isempty(args.parent_mesh1d)
                if isprop(args.parent_mesh2d,'parent_mesh')
                    args.parent_mesh1d = args.parent_mesh2d.parent_mesh;
                end
            end
            % ---
            if ~isempty(args.id_zline)
                defined_with = 'mesh1d2d';
            elseif ~isempty(args.mesh_file)
                defined_with = 'mesh_file';
            end
            % ---
            switch defined_with
                case 'mesh1d2d'
                    % ---
                    if isa(args.parent_mesh2d,'QuadMesh')
                        mtype = @HexaMeshFromQuadMesh;
                    elseif isa(args.parent_mesh2d,'TriMesh')
                        mtype = @PrismMeshFromTriMesh;
                    end
                    % ---
                    argu = f_to_namedarg(args,'with_only',...
                             {'parent_mesh1d','parent_mesh2d','id_zline'});
                    msh = mtype(argu{:});
                    % ---
                % ---------------------------------------------------------
                % --- XTODO
                case 'mesh_file'

                % ---------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function ltensor = make_ltensor(obj,args)
            arguments
                obj
                args.main_value mustBeNumeric = []
                args.ort1_value mustBeNumeric = []
                args.ort2_value mustBeNumeric = []
                args.main_dir mustBeNumeric = []
                args.ort1_dir mustBeNumeric = []
                args.ort2_dir mustBeNumeric = []
                args.rot_axis mustBeNumeric = []
                args.rot_angle mustBeNumeric = []
            end
            %--------------------------------------------------------------
            if isempty(args.rot_axis) || isempty(args.rot_angle)
                ltensor.main_dir = args.main_dir;
                ltensor.ort1_dir = args.ort1_dir;
                ltensor.ort2_dir = args.ort2_dir;
            else
                ltensor.main_dir = f_rotaroundaxis(args.main_dir,'rot_axis',args.rot_axis,'angle',args.rot_angle);
                ltensor.ort1_dir = f_rotaroundaxis(args.ort1_dir,'rot_axis',args.rot_axis,'angle',args.rot_angle);
                ltensor.ort2_dir = f_rotaroundaxis(args.ort2_dir,'rot_axis',args.rot_axis,'angle',args.rot_angle);
            end
        end
        % -----------------------------------------------------------------
        function ltensor = make_ltensoroxy(obj,args)
            arguments
                obj
                args.x_value mustBeNumeric = []
                args.y_value mustBeNumeric = []
                args.z_value mustBeNumeric = []
                args.rot_angle mustBeNumeric = []
            end
            %--------------------------------------------------------------
            ltensor.main_value = args.x_value;
            ltensor.ort1_value = args.y_value;
            ltensor.ort2_value = args.z_value;
            ltensor.main_dir = [+cosd(args.rot_angle) +sind(args.rot_angle) 0];
            ltensor.ort1_dir = [-sind(args.rot_angle) +cosd(args.rot_angle) 0];
            ltensor.ort2_dir = [0 0 1];
        end
        % -----------------------------------------------------------------
    end
end