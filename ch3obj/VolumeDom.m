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

classdef VolumeDom < MeshDom
    properties
        parent_mesh
        elem_code
        gindex
        condition
        gid
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_mesh','elem_code','gindex','condition'};
        end
    end
    % --- Constructors
    methods
        function obj = VolumeDom(args)
            arguments
                args.id
                args.parent_mesh
                args.elem_code
                args.gindex
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
            VolumeDom.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            % ---
            % must try elem_code first
            if ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            elseif ~isempty(obj.gindex)
                obj.build_from_gindex;
            end
        end
    end
    methods (Access = public)
        function reset(obj)
            VolumeDom.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function sm = submesh(obj)
            % --- need parent_mesh
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gindex);
            % -------------------------------------------------------------
            if isa(obj.parent_mesh,'TetraMesh')
                sm{1} = TetraMesh('node',node,'elem',elem);
            elseif isa(obj.parent_mesh,'PrismMesh')
                sm{1} = PrismMesh('node',node,'elem',elem);
            elseif isa(obj.parent_mesh,'HexMesh')
                sm{1} = HexMesh('node',node,'elem',elem);
            elseif isa(obj.parent_mesh,'TriMesh')
                sm{1} = TriMesh('node',node,'elem',elem);
            elseif isa(obj.parent_mesh,'QuadMesh')
                sm{1} = QuadMesh('node',node,'elem',elem);
            else
                sm = [];
            end
            sm{1}.gindex = obj.gindex;
            sm{1}.parent_mesh = obj.parent_mesh;
            % ---
        end
        % -----------------------------------------------------------------
        function gid = get_gid(obj)
            %--------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gindex);
            elem_type = obj.parent_mesh.elem_type;
            %--------------------------------------------------------------
            id_node = f_uniquenode(elem);
            id_edge = obj.parent_mesh.meshds.id_edge_in_elem(:,obj.gindex);
            id_edge = unique(id_edge);
            id_face = obj.parent_mesh.meshds.id_face_in_elem(:,obj.gindex);
            id_face = unique(id_face);
            %--------------------------------------------------------------
            bound_face = f_boundface(elem,node,'elem_type',elem_type);
            id_bound_face = f_findvecnd(bound_face,obj.parent_mesh.face);
            id_bound_node = f_uniquenode(bound_face);
            if isa(obj.parent_mesh,'Mesh3d')
                id_bound_edge = f_edgeinface(bound_face,obj.parent_mesh.edge);
            elseif isa(obj.parent_mesh,'Mesh2d')
                id_bound_edge = id_bound_face;
            end
            id_bound_edge = unique(id_bound_edge);
            %--------------------------------------------------------------
            id_inner_node = setdiff(id_node,id_bound_node);
            id_inner_edge = setdiff(id_edge,id_bound_edge);
            id_inner_face = setdiff(id_face,id_bound_face);
            %--------------------------------------------------------------
            gid.gid_elem = obj.gindex;
            gid.gid_node = id_node;
            gid.gid_edge = id_edge;
            gid.gid_face = id_face;
            %--------------------------------------------------------------
            gid.gid_bound_node = id_bound_node;
            gid.gid_bound_edge = id_bound_edge;
            gid.gid_bound_face = id_bound_face;
            %--------------------------------------------------------------
            gid.gid_inner_node = id_inner_node;
            gid.gid_inner_edge = id_inner_edge;
            gid.gid_inner_face = id_inner_face;
            %--------------------------------------------------------------
            obj.gid = gid;
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function [gindex, lindex] = get_cutelem(obj,args)
            arguments
                obj
                args.cut_equation = []
                args.tolerance = 1e-9;
            end
            % ---
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gindex);
            cut_equation = f_cut_equation(args.cut_equation);
            tol = args.tolerance;
            %--------------------------------------------------------------
            eqcond = cut_equation.eqcond;
            neqcond = cut_equation.neqcond;
            %--------------------------------------------------------------
            nbEqcond = length(eqcond);
            %--------------------------------------------------------------
            refelem = obj.parent_mesh.refelem;
            nbNo_inEl = refelem.nbNo_inEl;
            nbElem = size(elem,2);
            % ---
            x = reshape(node(1,elem(:,:)),nbNo_inEl,[]);
            y = reshape(node(2,elem(:,:)),nbNo_inEl,[]);
            z = reshape(node(3,elem(:,:)),nbNo_inEl,[]);
            % ---
            if length(neqcond) > 1                    % 1 & something else
                eval(['iNeqcond = (' neqcond ');']);
                checksum = sum(iNeqcond);
                % just need one node touched
                lindex = find(checksum >= 1);
            else
                lindex = 1:nbElem;
            end
            % ---
            for i = 1:nbEqcond
                eqcond_L = strrep(eqcond{i},'==',['<+' num2str(tol) '+']);
                eqcond_R = strrep(eqcond{i},'==',['>-' num2str(tol) '+']);
                eval(['iEqcond_L{i} = (' eqcond_L ');']);
                eval(['iEqcond_R{i} = (' eqcond_R ');']);
                checksum_L = sum(iEqcond_L{i});
                checksum_R = sum(iEqcond_R{i});
                checksum   = checksum_L + checksum_R;
                % just need one node touched
                iElemEqcond{i} = find((checksum_L > 0 & checksum_R > 0));
                % --- no tol
                %iElemEqcond{i} = find( (checksum_L < nbNo_inEl & checksum_L > 0 & ...
                %    checksum_R < nbNo_inEl & checksum_R > 0)  ...
                %    |(checksum   < nbNo_inEl));

            end
            % ---
            for i = 1:nbEqcond
                lindex = intersect(lindex,iElemEqcond{i});
            end
            %--------------------------------------------------------------
            lindex = unique(lindex);
            gindex = obj.gindex(lindex);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function [gid_node, lid_node] = get_cutnode(obj,args)
            arguments
                obj
                args.cut_equation = []
                args.tolerance = 1e-9;
            end
            %--------------------------------------------------------------
            IDNode = f_uniquenode(obj.parent_mesh.elem(:,obj.gindex));
            lnode  = obj.parent_mesh.node(:,IDNode);
            %--------------------------------------------------------------
            lid_node = f_findnode(lnode,'condition',args.cut_equation,...
                                        'tolerance',args.tolerance);
            %--------------------------------------------------------------
            gid_node = unique(IDNode(lid_node));
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function cut_dom = get_cutdom(obj,args)
            arguments
                obj
                args.cut_equation
            end
            %--------------------------------------------------------------
            [gindex_, lindex] = obj.get_cutelem('cut_equation',args.cut_equation);
            if isempty(gindex_)
                cut_dom.gindex = [];
                cut_dom.gid_side_node_1 = [];
                cut_dom.gid_side_node_2 = [];
                return
            end
            %--------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem_type = obj.parent_mesh.elem_type;
            cut_equation = f_cut_equation(args.cut_equation);
            % ---
            eqcond = cut_equation.eqcond;
            % ---
            elem1 = obj.parent_mesh.elem(:,gindex_);
            elem2 = obj.parent_mesh.elem(:,setdiff(obj.gindex,gindex_));
            % ---
            side_face = f_interface(elem1,elem2,node,'elem_type',elem_type);
            % ---
            id_side_node = f_uniquenode(side_face);
            % ---
            id_side_node(id_side_node == 0) = [];
            % ---
            x = node(1,id_side_node);
            y = node(2,id_side_node);
            z = node(3,id_side_node);
            % ---
            for i = 1:length(eqcond)
                eqcond_L = strrep(eqcond{i},'==','<');
                eqcond_R = strrep(eqcond{i},'==','>');
                eval(['checksum_L = (' eqcond_L ');']);
                eval(['checksum_R = (' eqcond_R ');']);
                lid_side_node_1{i} = id_side_node(checksum_L~=0);
                lid_side_node_2{i} = id_side_node(checksum_R~=0);
            end
            % ---
            gid_side_node_1 = [];
            gid_side_node_2 = [];
            for i = 1:length(eqcond)
                gid_side_node_1 = [gid_side_node_1 lid_side_node_1{i}];
                gid_side_node_2 = [gid_side_node_2 lid_side_node_2{i}];
            end
            %--------------------------------------------------------------
            cut_dom.gindex = gindex_;
            cut_dom.gid_side_node_1 = gid_side_node_1;
            cut_dom.gid_side_node_2 = gid_side_node_2;
            %--------------------------------------------------------------
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
    end

    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        function build_from_elem_code(obj)
            % ---
            if any(f_strcmpi(obj.elem_code,{':','all','all_domaine'}))
                obj.gindex = ':';
                obj.build_from_gindex;
                return
            end
            % ---
            gindex_ = [];
            for i = 1:length(obj.elem_code)
                gindex_ = [gindex_ f_torowv(find(obj.parent_mesh.elem_code == obj.elem_code(i)))];
            end
            % ---
            gindex_ = unique(gindex_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gindex_);
                % ---
                idElem = ...
                    f_findelem(node,elem,'condition', obj.condition);
                gindex_ = gindex_(idElem);
            end
            % -------------------------------------------------------------
            obj.gindex  = unique(gindex_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gindex_));
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function build_from_gindex(obj)
            % ---
            if any(f_strcmpi(obj.gindex,{':','all','all_domaine'}))
                obj.gindex = 1:obj.parent_mesh.nb_elem;
            end
            % ---
            gindex_ = obj.gindex;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gindex_);
                % ---
                idElem = ...
                    f_findelem(node,elem,'condition', obj.condition);
                gindex_ = gindex_(idElem);
            end
            % -------------------------------------------------------------
            obj.gindex  = unique(gindex_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gindex_));
            % -------------------------------------------------------------
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
                args.id = ''
            end
            % --- elem_code-info
            % elcode = [];
            % if ~isempty(obj.elem_code)
            %     codemin = min(obj.elem_code);
            %     codemax = max(obj.elem_code);
            %     if codemax == codemin
            %         elcode = num2str(codemax);
            %     else
            %         elcode = [num2str(codemin) '-' num2str(codemax)];
            %     end
            %     % ---
            %     elcode = [args.id ':' elcode];
            % end
            % ---
            % submesh_ = obj.submesh;
            % argu = f_to_namedarg(args,'with_out','id');
            % for i = 1:length(submesh_)
            %     submesh_{i}.plot(argu{:}); hold on
            %     % ---
            %     submesh_{i}.build_meshds('get','celem');
            %     cnode = submesh_{i}.celem(:,1);
            %     if length(cnode) == 2
            %         t = text(cnode(1),cnode(2),obj.id);
            %         t.FontWeight = 'bold';
            %     elseif length(cnode) == 3
            %         t = text(cnode(1),cnode(2),cnode(3),obj.id);
            %         t.FontWeight = 'bold';
            %     end
            % end
            % ----------------------------------------------------
            submesh_ = obj.submesh;
            argu = f_to_namedarg(args,'with_out','id');
            for i = 1:length(submesh_)
                submesh_{i}.plot(argu{:}); hold on
                % ---
                celem = submesh_{i}.cal_celem;
                celem = celem(:,1);
                id = replace(obj.id,'_','-');
                if length(celem) == 2
                    t = text(celem(1),celem(2),id);
                    t.FontWeight = 'bold';
                elseif length(celem) == 3
                    t = text(celem(1),celem(2),celem(3),id);
                    t.FontWeight = 'bold';
                end
            end
            % ----------------------------------------------------
        end
    end

    % --- Methods
    methods
        % XTODO
        % take care of passing dependent_obj, defining_obj
        % must call reset
        function objy = plus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gindex = [f_torowv(obj.gindex) f_torowv(objx.gindex)];
            objy.build_from_gindex;
            % ---
            % obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
        end
        function objy = minus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gindex = setdiff(f_torowv(obj.gindex),f_torowv(objx.gindex));
            objy.build_from_gindex;
            % ---
            % obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
        end
        function objy = mpower(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gindex = intersect(f_torowv(obj.gindex),f_torowv(objx.gindex));
            objy.build_from_gindex;
            % ---
            % obj.transfer_dep_def(objx,objy);
            % ---
            obj.is_defining_obj_of(objy);
            objx.is_defining_obj_of(objy);
        end
    end
end
