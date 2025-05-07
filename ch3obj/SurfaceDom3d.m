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

classdef SurfaceDom3d < SurfaceDom

    % --- Properties
    properties
        id_dom3d
    end

    % --- subfields to build
    properties
        
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_mesh','gid_face','condition', ...
                        'defined_on','id_dom3d'};
        end
    end
    % --- Constructors
    methods
        function obj = SurfaceDom3d(args)
            arguments
                % ---
                args.id = []
                args.parent_mesh = []
                args.gid_face = []
                args.condition = []
                % ---
                args.defined_on char = []
                args.id_dom3d
            end
            % ---
            obj = obj@SurfaceDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            SurfaceDom3d.setup(obj);
            % ---
        end
    end
    % --- setup
    methods (Static)
        function setup(obj)
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
            else
                switch lower(obj.defined_on)
                    case {'bound_face','bound'}
                        obj.build_from_boundface;
                    case {'interface'}
                        obj.build_from_interface;
                end
            end
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            SurfaceDom3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function build_from_boundface(obj)
            % ---
            id_dom3d_ = f_to_scellargin(obj.id_dom3d);
            all_id3   = fieldnames(obj.parent_mesh.dom);
            % ---
            elem = [];
            % ---
            for i = 1:length(id_dom3d_)
                id3 = id_dom3d_{i};
                valid3 = f_validid(id3,all_id3);
                % ---
                for j = 1:length(valid3)
                    % ---
                    dom3d = obj.parent_mesh.dom.(valid3{j});
                    dom3d.is_defining_obj_of(obj);
                    % ---
                    elem = [elem  obj.parent_mesh.elem(:,dom3d.gid_elem)];
                end
            end
            %--------------------------------------------------------------
            if isempty(elem)
                return
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
                    f_findelem(node,face,'condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            %--------------------------------------------------------------
            obj.gid_face = gid_face_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function  build_from_interface(obj)
            % ---
            id_dom3d_ = f_to_dcellargin(obj.id_dom3d,'forced','on');
            all_id3   = fieldnames(obj.parent_mesh.dom);
            node = obj.parent_mesh.node;
            % ---
            for i = 1:length(id_dom3d_)
                elem = [];
                for j = 1:length(id_dom3d_{i})
                    id3 = id_dom3d_{i}{j};
                    valid3 = f_validid(id3,all_id3);
                    for j = 1:length(valid3)
                        % ---
                        dom3d = obj.parent_mesh.dom.(valid3{j});
                        dom3d.is_defining_obj_of(obj);
                        % ---
                        elem = [elem  obj.parent_mesh.elem(:,obj.parent_mesh.dom.(valid3{j}).gid_elem)];
                    end
                end
                %--------------------------------------------------------------
                if isempty(elem)
                    xgid_face_{i} = [];
                    break;
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
                    f_findelem(node,face,'condition', obj.condition);
                gid_face_ = gid_face_(id_);
            end
            %--------------------------------------------------------------
            obj.gid_face = gid_face_;
            % -------------------------------------------------------------
        end
    end
end



