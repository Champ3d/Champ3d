%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef CloseCoilAphi < CloseCoil

    % --- computed
    properties
        build_done = 0
        matrix
    end

    % --- Contructor
    methods
        function obj = CloseCoilAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
            end
            % ---
            obj@CloseCoil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_done = 0;
            obj.build_done = 0;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            if obj.setup_done
                return
            end
            % ---
            setup@CloseCoil(obj);
            % ---
            obj.parent_mesh = obj.dom.parent_mesh;
            % ---
            obj.matrix.gid_elem = [];
            obj.matrix.unit_current_field = [];
            % ---
            obj.setup_done = 1;
            % ---
            obj.build_done = 0;
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            obj.setup;
            % ---
            if obj.build_done
                return
            end
            % ---
            parent_mesh = obj.dom.parent_mesh;
            parent_mesh.build_meshds;
            parent_mesh.build_discrete;
            parent_mesh.build_intkit;
            % --- current field
            unit_current_field = sparse(3,parent_mesh.nb_elem);
            % ---
            nbEd_inEl = parent_mesh.refelem.nbEd_inEl;
            % ---
            nb_node = parent_mesh.nb_node;
            nb_edge = parent_mesh.nb_edge;
            id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
            % ---
            for ipart = 1:2
                if ipart == 1
                    vdom = obj.electrode_dom;
                else
                    vdom = obj.shape_dom;
                end
                % ---
                gid_elem = vdom.gid_elem;
                gid_node_vdom = f_uniquenode(parent_mesh.elem(:,vdom.gid_elem));
                lwewe = parent_mesh.cwewe('id_elem',gid_elem);
                % ---
                gwewe = sparse(nb_edge,nb_edge);
                for j = 1:nbEd_inEl
                    for k = j+1 : nbEd_inEl
                        gwewe = gwewe + ...
                            sparse(id_edge_in_elem(j,gid_elem),id_edge_in_elem(j,gid_elem),...
                            lwewe(:,j,k),nb_edge,nb_edge);
                    end
                end
                gwewe = gwewe + gwewe.';
                for j = 1:nbEd_inEl
                    gwewe = gwewe + ...
                        sparse(id_edge_in_elem(j,gid_elem),id_edge_in_elem(j,gid_elem),...
                        lwewe(:,j,j),nb_edge,nb_edge);
                end
                % ---
                V = zeros(nb_node,1);
                V(vdom.gid_side_node_1) = 1;
                % ---
                id_node_v_unknown = setdiff(gid_node_vdom,...
                    [vdom.gid_side_node_1 vdom.gid_side_node_2]);
                % ---
                if ~isempty(id_node_v_unknown)
                    gradgrad = parent_mesh.discrete.grad.' * gwewe * parent_mesh.discrete.grad;
                    RHS = - gradgrad * V;
                    gradgrad = gradgrad(id_node_v_unknown,id_node_v_unknown);
                    RHS = RHS(id_node_v_unknown,1);
                    V(id_node_v_unknown) = gradgrad \ RHS;
                end
                % ---
                dofJs = parent_mesh.discrete.grad * V;
                vJs = parent_mesh.field_we('dof',dofJs,'id_elem',gid_elem);
                vJs = f_normalize(vJs);
                % ---
                unit_current_field = unit_current_field + vJs;
            end
            % ---
            % current turn density vector field
            % current_turn_density  = current_field .* nb_turn ./ cs_area;
            % ---
            obj.matrix.gid_elem = obj.dom.gid_elem;
            obj.matrix.unit_current_field = unit_current_field;
            % ---
            obj.build_done = 1;
        end
    end

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'k'
                args.face_color = 'none'
                args.alpha {mustBeNumeric} = 0.5
            end
            % ---
            argu = f_to_namedarg(args);
            plot@CloseCoil(obj,argu{:});
            % ---
            if ~isempty(obj.matrix.unit_current_field)
                hold on;
                f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gid_elem), ...
                         obj.matrix.unit_current_field(:,obj.matrix.gid_elem));
            end
        end
    end

end