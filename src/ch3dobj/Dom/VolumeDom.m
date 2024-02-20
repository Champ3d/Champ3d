%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom < Xhandle

    % --- Properties
    properties
        parent_mesh
        elem_code
        gid_elem
        condition
        submesh
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = VolumeDom(args)
            arguments
                % ---
                args.parent_mesh = []
                args.elem_code = []
                args.gid_elem = []
                args.condition = []
            end
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.gid_elem)
                obj.build_from_gid_elem;
            elseif ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            end
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function allmeshes = build_submesh(obj)
            % ---
            if ~isempty(obj.submesh)
                allmeshes = obj.submesh;
                return
            end
            % ---
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gid_elem);
            % -------------------------------------------------------------
            allmeshes{1} = feval(class(obj.parent_mesh),'node',node,'elem',elem);
            allmeshes{1}.gid_elem = obj.gid_elem;
            allmeshes{1}.parent_mesh = obj.parent_mesh;
            % ---
            obj.submesh = allmeshes;
        end
        % -----------------------------------------------------------------
        function gid = gid(obj)
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gid_elem);
            elem_type = obj.parent_mesh.elem_type;
            %--------------------------------------------------------------
            id_node = f_uniquenode(elem);
            id_edge = obj.parent_mesh.meshds.id_edge_in_elem(:,obj.gid_elem);
            id_edge = unique(id_edge);
            id_face = obj.parent_mesh.meshds.id_face_in_elem(:,obj.gid_elem);
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
            gid.gid_elem = obj.gid_elem;
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
        end
        % -----------------------------------------------------------------
        function [gid_elem, lid_elem] = get_cutelem(obj,args)
            arguments
                obj
                args.cut_equation = []
            end
            % ---
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gid_elem);
            elem_type = obj.parent_mesh.elem_type;
            cut_equation = f_cut_equation(args.cut_equation);
            %--------------------------------------------------------------
            eqcond = cut_equation.eqcond;
            neqcond = cut_equation.neqcond;
            %--------------------------------------------------------------
            nbEqcond = length(eqcond);
            %--------------------------------------------------------------
            con = f_connexion(elem_type);
            nbNo_inEl = con.nbNo_inEl;
            nbElem = size(elem,2);
            % ---
            x = zeros(nbNo_inEl,nbElem);
            y = zeros(nbNo_inEl,nbElem);
            z = zeros(nbNo_inEl,nbElem);
            % ---
            for i = 1:nbNo_inEl
                x(i,:) = node(1,elem(i,:));
                y(i,:) = node(2,elem(i,:));
                z(i,:) = node(3,elem(i,:));
            end
            % ---
            if length(neqcond) > 1                    % 1 & something else
                eval(['iNeqcond = (' neqcond ');']);
                eval('checksum = sum(iNeqcond);');
                % just need one node touched
                lid_elem = find(checksum >= 1);
            else
                lid_elem = 1:nbElem;
            end
            % ---
            for i = 1:nbEqcond
                eqcond_L = strrep(eqcond{i},'==','<');
                eqcond_R = strrep(eqcond{i},'==','>');
                eval(['iEqcond_L{i} = (' eqcond_L ');']);
                eval(['iEqcond_R{i} = (' eqcond_R ');']);
                checksum_L = sum(iEqcond_L{i});
                checksum_R = sum(iEqcond_R{i});
                checksum   = checksum_L + checksum_R;
                % just need one node touched
                iElemEqcond{i} = find( (checksum_L < nbNo_inEl & checksum_L > 0 & ...
                    checksum_R < nbNo_inEl & checksum_R > 0)  ...
                    |(checksum   < nbNo_inEl));
            end
            % ---
            for i = 1:nbEqcond
                lid_elem = intersect(lid_elem,iElemEqcond{i});
            end
            %--------------------------------------------------------------
            lid_elem = unique(lid_elem);
            gid_elem = obj.gid_elem(lid_elem);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function [gid_node, lid_node] = get_cutnode(obj,args)
            arguments
                obj
                args.cut_equation = []
            end
            % ---
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gid_elem);
            cut_equation = f_cut_equation(args.cut_equation);
            %--------------------------------------------------------------
            eqcond = cut_equation.eqcond;
            neqcond = cut_equation.neqcond;
            %--------------------------------------------------------------
            nbEqcond = length(eqcond);
            %--------------------------------------------------------------
            IDNode = f_uniquenode(elem);
            x = node(1,IDNode);
            y = node(2,IDNode);
            z = node(3,IDNode);
            %--------------------------------------------------------------
            checksum = [];
            neqNode  = [];
            %--------------------------------------------------------------
            if length(neqcond) > 1                     % 1 & something else
                eval(['checksum = (' neqcond ');']);
                neqNode = find(checksum);
            else
                neqNode = 1:length(IDNode);
            end
            %--------------------------------------------------------------
            for i = 1:nbEqcond
                eqc = eqcond{i};
                isep = strfind(eqc,'==');
                eqcond_L = eqc(1:isep-1);
                eqcond_R = eqc(isep+2:end);
                % == with tolerance
                eqc = [eqcond_L '<=' eqcond_R '+' num2str(tol) ' & ' ...
                    eqcond_L '>=' eqcond_R '-' num2str(tol)];
                eval(['checksum = (' eqc ');']);
                eqNode{i} = find(checksum);
            end
            %--------------------------------------------------------------
            eNode = neqNode;
            for i = 1:nbEqcond
                eNode = intersect(eNode,eqNode{i});
            end
            eNode(eNode == 0) = [];
            %--------------------------------------------------------------
            lid_node = unique(eNode);
            gid_node = unique(IDNode(eNode));
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function cut_dom = get_cutdom(obj,args)
            arguments
                obj
                args.cut_equation
            end
            % ---
            [gid_elem_, lid_elem] = obj.get_cutelem(args.cut_equation);
            % ---
            node = obj.parent_mesh.node;
            elem_type = obj.parent_mesh.elem_type;
            cut_equation = f_cut_equation(args.cut_equation);
            %--------------------------------------------------------------
            eqcond = cut_equation.eqcond;
            % ---
            elem1 = obj.parent_mesh.elem(:,gid_elem_);
            elem2 = obj.parent_mesh.elem(:,setdiff(1:obj.parent_mesh.nb_elem,gid_elem_));
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
            for i = 1:nbEqcond
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
            for i = 1:nbEqcond
                gid_side_node_1 = [gid_side_node_1 lid_side_node_1{i}];
                gid_side_node_2 = [gid_side_node_2 lid_side_node_2{i}];
            end
            %--------------------------------------------------------------
            cut_dom.gid_elem = gid_elem_;
            cut_dom.gid_side_node_1 = gid_side_node_1;
            cut_dom.gid_side_node_2 = gid_side_node_2;
            %--------------------------------------------------------------
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function build_from_elem_code(obj)
            % ---
            if any(f_strcmpi(obj.elem_code,{':','all','all_domaine'}))
                obj.gid_elem = ':';
                obj.build_from_gid_elem;
                return
            end
            % ---
            gid_elem_ = [];
            for i = 1:length(obj.elem_code)
                gid_elem_ = [gid_elem_ f_torowv(find(obj.parent_mesh.elem_code == obj.elem_code(i)))];
            end
            % ---
            gid_elem_ = unique(gid_elem_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gid_elem_);
                elem_type = obj.parent_mesh.elem_type;
                % ---
                idElem = ...
                    f_find_elem(node,elem,'condition', obj.condition);
                gid_elem_ = gid_elem_(idElem);
            end
            % -------------------------------------------------------------
            obj.gid_elem  = unique(gid_elem_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gid_elem_));
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function build_from_gid_elem(obj)
            % ---
            if any(f_strcmpi(obj.gid_elem,{':','all','all_domaine'}))
                obj.gid_elem = 1:obj.parent_mesh.nb_elem;
            end
            % ---
            gid_elem_ = obj.gid_elem;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gid_elem_);
                elem_type = obj.parent_mesh.elem_type;
                % ---
                idElem = ...
                    f_find_elem(node,elem,'condition', obj.condition);
                gid_elem_ = gid_elem_(idElem);
            end
            % -------------------------------------------------------------
            obj.gid_elem  = unique(gid_elem_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gid_elem_));
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'none'
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            obj.build_submesh;
            submesh_ = obj.submesh;
            argu = f_to_namedarg(args);
            for i = 1:length(submesh_)
                submesh_{i}.plot(argu{:}); hold on
                delete(submesh_{i});
            end
        end
    end

    % --- Methods
    methods
        function objy = plus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = [f_torowv(obj.gid_elem) f_torowv(objx.gid_elem)];
            objy.build_from_gid_elem;
        end
        function objy = minus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = setdiff(f_torowv(obj.gid_elem),f_torowv(objx.gid_elem));
            objy.build_from_gid_elem;
        end
        function objy = mpower(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = intersect(f_torowv(obj.gid_elem),f_torowv(objx.gid_elem));
            objy.build_from_gid_elem;
        end
    end

end
