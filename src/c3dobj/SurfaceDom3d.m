%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SurfaceDom3d < SurfaceDom

    % --- Properties
    properties
        dom3d_collection
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = SurfaceDom3d(args)
            arguments
                % ---
                args.parent_mesh
                args.id_face = []
                args.build_from = []
                args.condition = []
                % ---
                args.defined_on char = []
                args.dom3d_collection Dom3dCollection
            end
            % ---
            obj <= args;
            % ---
            if isempty(args.id_face)
                obj.build_from = 'id_face';
            else
                switch lower(args.defined_on)
                    case {'bound_face','bound'}
                        obj.build_from = 'bound_face';
                    case {'interface'}
                        obj.build_from = 'inter_face';
                end
            end
        end
    end

    % --- Methods
    methods
        function allmeshes = submesh(obj)
            switch obj.build_from
                case 'bound_face'
                    allmeshes = obj.build_from_boundface;
                case 'interface'
                    allmeshes = obj.build_from_interface;
                case 'id_face'
                    allmeshes = obj.build_from_id_face;
            end
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function allmeshes = build_from_id_face(obj)
            id_face_ = obj.id_face;
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                id_face_ = id_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,id_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function allmeshes = build_from_boundface(obj)
            id_face_ = obj.id_face;
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                id_face_ = id_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,id_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function allmeshes = build_from_interface(obj)
            id_face_ = obj.id_face;
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                id_face_ = id_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,id_face_);
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,id_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function allmeshes = decompose_face(obj,node,face,gid_face)
            arguments
                obj, node, face, gid_face
            end
            % ---
            nb_face = size(face,2);
            % ---
            id_tria = find(face(4,:) == 0);
            id_quad = setdiff(1:nb_face,id_tria);
            % ---
            allmeshes{1} = TriMesh('node',node,'elem',face(1:3,id_tria));
            allmeshes{1}.gid_elem = gid_face(id_tria);
            % ---
            allmeshes{2} = QuadMesh('node',node,'elem',face(1:4,id_quad));
            allmeshes{2}.gid_elem = gid_face(id_quad);
        end
        % -----------------------------------------------------------------
    end

end



