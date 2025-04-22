%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SurfaceDom < Xhandle

    % --- Properties
    properties
        gid_face
        defined_on
        condition
        submesh
    end

    % --- subfields to build
    properties
        parent_mesh
    end

    % --- subfields to build
    properties
        building_formular
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    properties
        dependent_obj = []
        defining_obj = []
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','gid_face','defined_on','condition'};
        end
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
            obj = obj@Xhandle;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            SurfaceDom.setup(obj);
            % ---
        end
    end
    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % --- XTODO : which come first
            % build_from_boundface
            % build_from_interface
            % build_from_gid_face
            % if ~isempty(obj.gid_face)
            %     obj.build_from_gid_face;
            % end
            % ---
            if ~isempty(obj.building_formular)
                if ~isempty(obj.building_formular.arg1) && ...
                   ~isempty(obj.building_formular.arg2) && ...
                   ~isempty(obj.building_formular.operation)
                    obj.build_from_formular;
                end
            end
            % ---
            fprintf('SurfaceDom setup \n')
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % ---
            obj.setup_done = 0;
            SurfaceDom.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            SurfaceDom.setup(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_defining_obj;
            % ---
            obj.build_done = 1;
            % ---
        end
    end

    % --- Methods
    methods
        function allmeshes = build_submesh(obj)
            % ---
            % if ~isempty(obj.submesh)
            %     allmeshes = obj.submesh;
            %     for i = 1:length(allmeshes)
            %         allmeshes{i}.node = obj.parent_mesh.node;
            %     end
            %     return
            % end
            % --- need parent_mesh
            node = obj.parent_mesh.node;
            face = obj.parent_mesh.face(:,obj.gid_face);
            % ---
            nb_face = size(face,2);
            % ---
            id_tria = find(face(4,:) == 0);
            id_quad = setdiff(1:nb_face,id_tria);
            % ---
            nb_sm = 0;
            if ~isempty(id_tria)
                nb_sm = nb_sm + 1;
                allmeshes{nb_sm} = TriMesh('node',node,'elem',face(1:3,id_tria));
                allmeshes{nb_sm}.gid_face = obj.gid_face(id_tria);
                allmeshes{nb_sm}.lid_face = id_tria;
                allmeshes{nb_sm}.parent_mesh = obj.parent_mesh;
            end
            if ~isempty(id_quad)
                nb_sm = nb_sm + 1;
                allmeshes{nb_sm} = QuadMesh('node',node,'elem',face(1:4,id_quad));
                allmeshes{nb_sm}.gid_face = obj.gid_face(id_quad);
                allmeshes{nb_sm}.lid_face = id_quad;
                allmeshes{nb_sm}.parent_mesh = obj.parent_mesh;
            end
            % ---
            if nb_sm == 0
                allmeshes{1} = Mesh;
            end
            % ---
            obj.submesh = allmeshes;
        end
    end

    % --- Methods
    methods (Access = protected)
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
                    f_findelem(node,face,'condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            % -------------------------------------------------------------
            obj.gid_face = unique(gid_face_);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function build_from_formular(obj)
            % ---
            building_formular_ = obj.building_formular;
            % ---
            resobj = [];
            for i = 1:length(obj.building_formular.operation)
                dom1 = obj.building_formular.arg1{i};
                dom2 = obj.building_formular.arg2{i};
                oper = obj.building_formular.operation{i};
                if i == 1
                    switch oper
                        case '+'
                            resobj = (dom1 + dom2);
                        case '-'
                            resobj = (dom1 - dom2);
                        case '^'
                            resobj = (dom1 ^ dom2);
                    end
                elseif i > 1
                    switch oper
                        case '+'
                            resobj = resobj + (dom1 + dom2);
                        case '-'
                            resobj = resobj + (dom1 - dom2);
                        case '^'
                            resobj = resobj + (dom1 ^ dom2);
                    end
                end
            end
            % ---
            obj = resobj;
            obj.building_formular = building_formular_;
            % ---
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
            end
            % ---
            obj.build_submesh;
            submesh_ = obj.submesh;
            argu = f_to_namedarg(args);
            for i = 1:length(submesh_)
                submesh_{i}.plot(argu{:}); hold on
            end
            % ---
        end
    end

    % --- Methods
    methods
        function objy = plus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = [f_torowv(obj.gid_face) f_torowv(objx.gid_face)];
            objy.build_from_gid_face;
            % ---
            %obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
            % ---
            if isfield(objy.building_formular,'operation')
                len = length(objy.building_formular.operation);
            else
                objy.building_formular.arg1 = [];
                objy.building_formular.arg2 = [];
                objy.building_formular.operation = [];
                len = 0;
            end
            objy.building_formular.arg1{len+1} = obj;
            objy.building_formular.arg2{len+1} = objx;
            objy.building_formular.operation{len+1} = '+';
            % ---
        end
        function objy = minus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = setdiff(f_torowv(obj.gid_face),f_torowv(objx.gid_face));
            objy.build_from_gid_face;
            % ---
            %obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
            % ---
            if isfield(objy.building_formular,'operation')
                len = length(objy.building_formular.operation);
            else
                objy.building_formular.arg1 = [];
                objy.building_formular.arg2 = [];
                objy.building_formular.operation = [];
                len = 0;
            end
            objy.building_formular.arg1{len+1} = obj;
            objy.building_formular.arg2{len+1} = objx;
            objy.building_formular.operation{len+1} = '-';
            % ---
        end
        function objy = mpower(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_face = intersect(f_torowv(obj.gid_face),f_torowv(objx.gid_face));
            objy.build_from_gid_face;
            % ---
            %obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
            % ---
            if isfield(objy.building_formular,'operation')
                len = length(objy.building_formular.operation);
            else
                objy.building_formular.arg1 = [];
                objy.building_formular.arg2 = [];
                objy.building_formular.operation = [];
                len = 0;
            end
            objy.building_formular.arg1{len+1} = obj;
            objy.building_formular.arg2{len+1} = objx;
            objy.building_formular.operation{len+1} = '^';
            % ---
        end
    end

end
