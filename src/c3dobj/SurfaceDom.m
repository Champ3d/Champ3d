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
        parent_mesh
        gid_face
        defined_on
        condition
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = SurfaceDom(args)
            arguments
                % ---
                args.parent_mesh = []
                args.gid_face = []
                args.defined_on = []
                args.condition = []
            end
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.gid_face)
                obj.build_from_gid_face;
            end
        end
    end

    % --- Methods
    methods
        function allmeshes = submesh(obj)
            % ---
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,obj.gid_face);
            % ---
            nb_face = size(face,2);
            % ---
            id_tria = find(face(4,:) == 0);
            id_quad = setdiff(1:nb_face,id_tria);
            % ---
            allmeshes{1} = TriMesh('node',node,'elem',face(1:3,id_tria));
            allmeshes{1}.gid_face = obj.gid_face(id_tria);
            % ---
            allmeshes{2} = QuadMesh('node',node,'elem',face(1:4,id_quad));
            allmeshes{2}.gid_face = obj.gid_face(id_quad);
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function build_from_gid_face(obj)
            % ---
            if any(f_strcmpi(obj.gid_face,{':','all','all_domaine'}))
                obj.gid_face = 1:obj.parent_mesh.nb_face;
            end
            % ---
            gid_face_ = obj.gid_face;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % -------------------------------------------------------------
                node = obj.parent_mesh.node;
                face = obj.parent_mesh.face(:,gid_face_);
                % ---
                id_ = ...
                    f_find_elem(node,face,'condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            % -------------------------------------------------------------
            obj.gid_face = unique(gid_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function objy = plus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = [f_torowv(obj.gid_face) f_torowv(objx.gid_face)];
            objy.build_from_gid_face;
        end
        function objy = minus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = setdiff(f_torowv(obj.gid_face),f_torowv(objx.gid_face));
            objy.build_from_gid_face;
        end
        function objy = mpower(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = intersect(f_torowv(obj.gid_face),f_torowv(objx.gid_face));
            objy.build_from_gid_face;
        end
    end

end
