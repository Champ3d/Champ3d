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
                args.condition = []
                % ---
                args.defined_on char = []
                args.dom3d_collection Dom3dCollection
                args.id_dom3d
            end
            % ---
            obj = obj@SurfaceDom;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.gid_face)
                obj.build_from_gid_face
            else
                switch lower(obj.defined_on)
                    case {'bound_face','bound'}
                        obj.build_from_boundface;
                    case {'interface'}
                        obj.build_from_interface;
                end
            end
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function build_from_boundface(obj)
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
                    elem = [elem  obj.parent_mesh.elem(:,obj.dom3d_collection.data.(valid3{j}).gid_elem)];
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
            %--------------------------------------------------------------
            obj.gid_face = gid_face_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function  build_from_interface(obj)
            % ---
            id_dom3d_ = f_to_dcellargin(obj.id_dom3d);
            all_id3   = fieldnames(obj.dom3d_collection.data);
            node = obj.parent_mesh.node;
            % ---
            for i = 1:length(id_dom3d_)
                elem = [];
                for j = 1:length(id_dom3d_{i})
                    id3 = id_dom3d_{i}{j};
                    valid3 = f_validid(id3,all_id3);
                    for j = 1:length(valid3)
                        elem = [elem  obj.parent_mesh.elem(:,obj.dom3d_collection.data.(valid3{j}).gid_elem)];
                    end
                end
                %----------------------------------------------------------
                elem_type = f_elemtype(elem);
                %----------------------------------------------------------
                face = f_boundface(elem,node,'elem_type',elem_type);
                xgid_face_{i} = f_findvecnd(face,obj.parent_mesh.face);
            end
            % ---
            gid_face_ = [];
            for i = 1:length(xgid_face_)
                if i == 1
                    gid_face_ = xgid_face_{i};
                else
                    gid_face_ = intersect(gid_face_,xgid_face_{i});
                end
            end
            % ---
            face = obj.parent_mesh.face(:,gid_face_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                id_ = ...
                    f_find_elem(node,face,'defined_on','face','condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            %--------------------------------------------------------------
            obj.gid_face = gid_face_;
            % -------------------------------------------------------------

        end
    end

end



