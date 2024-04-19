%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef GeoModel < Xhandle
    properties
        info 
        mesh1d_collection Mesh1dCollection
        mesh2d_collection Mesh2dCollection
        mesh3d_collection Mesh3dCollection
        dom2d_collection  Dom2dCollection
        dom3d_collection  Dom3dCollection
    end

    % --- Constructors
    methods
        function obj = GeoModel(args)
            arguments
                args.info = 'no_info';
            end
            % ---
            obj.info = args.info;
            % ---
            obj.mesh1d_collection = Mesh1dCollection;
            obj.mesh2d_collection = Mesh2dCollection;
            obj.mesh3d_collection = Mesh3dCollection;
            obj.dom2d_collection  = Dom2dCollection;
            obj.dom3d_collection  = Dom3dCollection;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function add_mesh1d(obj,args)
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
                line = Mesh1d(obj.tmp.args{:});
                obj.mesh1d_collection.data.(args.id) = line;
            end
        end
        % -----------------------------------------------------------------
        function add_mesh2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d_collection = []
                args.id_xline = []
                args.id_yline = []
                % ---
                args.mesh_file = []
            end
            % ---
            if isempty(args.mesh1d_collection)
                args.mesh1d_collection = obj.mesh1d_collection;
            end
            % ---
            if obj.is_available(args,'mesh_file')
                msh = TriMeshFromFemm(obj.tmp.args{:});
                obj.mesh2d_collection.data.(args.id) = msh;
            elseif obj.is_available(args,{'mesh1d_collection','id_xline','id_yline'})
                msh = QuadMeshFrom1d(obj.tmp.args{:});
                obj.mesh2d_collection.data.(args.id) = msh;
            end
        end
        % -----------------------------------------------------------------
        function add_vdom2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh = []
                args.mesh2d_collection = []
                args.id_mesh2d = []
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args = obj.getargs(args);
            % ---
            argu = f_to_namedarg(args,'with_only',...
                         {'parent_mesh','id_xline','id_yline','elem_code',...
                          'gid_elem','condition'});
            vdom = VolumeDom2d(argu{:});
            obj.dom2d_collection.data.(args.id) = vdom;
            % ---
        end
        % -----------------------------------------------------------------
        function add_mesh3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d_collection = []
                args.mesh2d_collection = []
                args.id_mesh2d char = []
                args.id_zline = []
                % ---
                args.mesh_file = []
            end
            % ---
            args = obj.getargs(args);
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
                    if isa(args.mesh2d_collection.data.(args.id_mesh2d),'QuadMesh')
                        mtype = @HexaMeshFromQuadMesh;
                    elseif isa(args.mesh2d_collection.data.(args.id_mesh2d),'TriMesh')
                        mtype = @PrismMeshFromTriMesh;
                    end
                    % ---
                    argu = f_to_namedarg(args,'with_only',...
                             {'mesh2d_collection','id_mesh2d','mesh1d_collection','id_zline'});
                    msh = mtype(argu{:});
                    % ---
                    obj.mesh3d_collection.data.(args.id) = msh;
                % ---------------------------------------------------------
                case 'mesh_file'

                % ---------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function add_vdom3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh = []
                args.mesh3d_collection = []
                args.id_mesh3d = []
                % ---
                args.dom2d_collection = []
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args = obj.getargs(args);
            % ---
            argu = f_to_namedarg(args,'with_only',...
                {'parent_mesh','dom2d_collection','id_dom2d','id_zline',...
                 'elem_code','gid_elem','condition'});
            vdom = VolumeDom3d(argu{:});
            obj.dom3d_collection.data.(args.id) = vdom;
            % ---
        end
        % -----------------------------------------------------------------
        function add_sdom3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh = []
                args.mesh3d_collection = []
                args.id_mesh3d = []
                % ---
                args.dom3d_collection = []
                args.id_dom3d = []
                % ---
                args.defined_on char = []
                % ---
                args.elem_code = []
                args.gid_face = []
                args.condition char = []
            end
            % ---
            args = obj.getargs(args);
            % ---
            argu = f_to_namedarg(args,'with_only',...
                {'parent_mesh','dom3d_collection','id_dom3d','defined_on',...
                 'gid_face','condition'});
            sdom = SurfaceDom3d(argu{:});
            obj.dom3d_collection.data.(args.id) = sdom;
            % ---
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end