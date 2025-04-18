%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef OpenCoilAphi < OpenCoil

    % --- computed
    properties
        matrix
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = OpenCoil.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = OpenCoilAphi(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
            end
            % ---
            obj@OpenCoil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            OpenCoilAphi.setup(obj);
            % ---
            % must reset build+assembly
            obj.build_done = 0;
            obj.assembly_done = 0;
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@OpenCoil(obj);
            % ---
            obj.setup_done = 1;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % ---
            % must reset setup+build+assembly
            obj.setup_done = 0;
            obj.build_done = 0;
            obj.assembly_done = 0;
            % ---
            % must call super reset
            % ,,, with obj as argument
            reset@OpenCoil(obj);
        end
    end
    methods
        function build(obj)
            % ---
            OpenCoilAphi.setup(obj);
            % ---
            build@OpenCoil(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            parent_mesh = obj.dom.parent_mesh;
            %parent_mesh.build_meshds;
            %parent_mesh.build_discrete;
            %parent_mesh.build_intkit;
            % --- current field
            unit_current_field = sparse(3,parent_mesh.nb_elem);
            % ---
            nbEd_inEl = parent_mesh.refelem.nbEd_inEl;
            % ---
            nb_node = parent_mesh.nb_node;
            nb_edge = parent_mesh.nb_edge;
            id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
            % ---
            vdom = obj.dom;
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
            V(obj.gid_node_petrode) = 1;
            % ---
            id_node_v_unknown = setdiff(gid_node_vdom,...
                [obj.gid_node_petrode obj.gid_node_netrode]);
            % ---
            if ~isempty(id_node_v_unknown)
                gradgrad = parent_mesh.discrete.grad.' * gwewe * parent_mesh.discrete.grad;
                RHS = - gradgrad * V;
                gradgrad = gradgrad(id_node_v_unknown,id_node_v_unknown);
                RHS = RHS(id_node_v_unknown,1);
                V(id_node_v_unknown) = f_solve_axb(gradgrad,RHS);
            end
            % ---
            dofJs = parent_mesh.discrete.grad * V;
            vJs = parent_mesh.field_we('dof',dofJs,'id_elem',gid_elem);
            vJs = f_normalize(vJs);
            % ---
            unit_current_field = unit_current_field + vJs;
            % ---
            % current turn density vector field
            % current_turn_density  = current_field .* nb_turn ./ cs_area;
            % ---
            obj.matrix.gid_elem = obj.dom.gid_elem;
            obj.matrix.unit_current_field = unit_current_field;
            obj.matrix.alpha = V;
            % ---
            obj.build_done = 1;
        end
    end
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@OpenCoil(obj);
            % ---
            if obj.assembly_done
                return
            end
            % ---
            obj.assembly_done = 1;
            % ---
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
            plot@OpenCoil(obj,argu{:});
            % ---
            if isfield(obj.matrix,'unit_current_field')
                if ~isempty(obj.matrix.unit_current_field)
                    hold on;
                    f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gid_elem), ...
                             obj.matrix.unit_current_field(:,obj.matrix.gid_elem),'sfactor',0.2);
                end
            end
        end
    end
end