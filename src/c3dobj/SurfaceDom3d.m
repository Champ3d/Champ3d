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
        id_dom3d
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
                args.gid_face = []
                args.build_from = []
                args.condition = []
                % ---
                args.defined_on char = []
                args.dom3d_collection Dom3dCollection
                args.id_dom3d
            end
            % ---
            obj <= args;
            % ---
            if isempty(obj.gid_face)
                obj.build_from = 'gid_face';
            else
                switch lower(obj.defined_on)
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
                case 'gid_face'
                    allmeshes = obj.build_from_gid_face;
            end
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function allmeshes = build_from_gid_face(obj)
            gid_face_ = obj.gid_face;
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,gid_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,gid_face_);
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,gid_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function allmeshes = build_from_boundface(obj)
            % ---
            id_dom3d_ = f_to_scellargin(obj.id_dom3d);
            all_id3   = fieldnames(obj.dom3d_collection.data);
            % ---
            elem = [];
            % ---
            for i = 1:length(id_dom3d_)
                id3 = id_dom3d_{i};
                valid3 = f_validid(id3,all_id3);
                % ---
                for j = 1:length(valid3)
                    elem = [elem  obj.parent_mesh.elem(:,obj.dom3d_collection.data.(valid3(j)).id_elem)];
                end
            end
            %--------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem_type = f_elemtype(elem);
            %--------------------------------------------------------------
            face = f_boundface(elem,node,'elem_type',elem_type);
            gid_face_ = f_findvecnd(face,obj.parent_mesh.face);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,gid_face_);
            %--------------------------------------------------------------
            obj.gid_face = gid_face_;
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,gid_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function allmeshes = build_from_interface(obj)
            gid_face_ = obj.gid_face;
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,gid_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            % -------------------------------------------------------------
            face = obj.parent_mesh.face(:,gid_face_);
            % -------------------------------------------------------------
            allmeshes = obj.decompose_face(node,face,gid_face_);
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
            allmeshes{1}.gid_face = gid_face(id_tria);
            % ---
            allmeshes{2} = QuadMesh('node',node,'elem',face(1:4,id_quad));
            allmeshes{2}.gid_face = gid_face(id_quad);
        end
        % -----------------------------------------------------------------
    end

end



