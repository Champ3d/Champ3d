%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SurfaceDom < MeshDom
    properties
        parent_mesh
        gid_face
        defined_on
        condition
        % ---
        building_formular
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_mesh','gid_face','defined_on','condition'};
        end
    end
    % --- Constructors
    methods
        function obj = SurfaceDom(args)
            arguments
                args.id
                args.parent_mesh
                args.gid_face
                args.defined_on
                args.condition
            end
            % ---
            obj = obj@MeshDom;
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
            if ~isempty(obj.building_formular)
                if ~isempty(obj.building_formular.arg1) && ...
                   ~isempty(obj.building_formular.arg2) && ...
                   ~isempty(obj.building_formular.operation)
                    obj.build_from_formular;
                end
            end
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            SurfaceDom.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        function sm = submesh(obj)
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
                sm{nb_sm} = TriMesh('node',node,'elem',face(1:3,id_tria));
                sm{nb_sm}.gid_face = obj.gid_face(id_tria);
                sm{nb_sm}.lid_face = id_tria;
                sm{nb_sm}.parent_mesh = obj.parent_mesh;
            end
            if ~isempty(id_quad)
                nb_sm = nb_sm + 1;
                sm{nb_sm} = QuadMesh('node',node,'elem',face(1:4,id_quad));
                sm{nb_sm}.gid_face = obj.gid_face(id_quad);
                sm{nb_sm}.lid_face = id_quad;
                sm{nb_sm}.parent_mesh = obj.parent_mesh;
            end
            % ---
            if nb_sm == 0
                sm{1} = Mesh;
            end
            % ---
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
            gid_face_ = [];
            for i = 1:length(obj.building_formular.operation)
                dom1 = obj.building_formular.arg1{i};
                dom2 = obj.building_formular.arg2{i};
                oper = obj.building_formular.operation{i};
                if i == 1
                    switch oper
                        case '+'
                            gid_face_ = f_unique([f_torowv(dom1.gid_face), f_torowv(dom2.gid_face)].');
                        case '-'
                            gid_face_ = f_unique(setdiff(f_torowv(dom1.gid_face),f_torowv(dom2.gid_face)).');
                        case '^'
                            gid_face_ = f_unique(intersect(f_torowv(dom1.gid_face),f_torowv(dom2.gid_face)).');
                    end
                elseif i > 1
                    switch oper
                        case '+'
                            
                        case '-'
                            
                        case '^'
                            
                    end
                end
            end
            % ---
            obj.gid_face = gid_face_;
            obj.build_from_gid_face;
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
            objy.gid_face = f_unique([f_torowv(obj.gid_face), f_torowv(objx.gid_face)].');
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
            objy.gid_face = f_unique(setdiff(f_torowv(obj.gid_face),f_torowv(objx.gid_face)).');
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
            objy.gid_face = f_unique(intersect(f_torowv(obj.gid_face),f_torowv(objx.gid_face)).');
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
