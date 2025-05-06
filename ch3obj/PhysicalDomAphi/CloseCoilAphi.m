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

classdef CloseCoilAphi < CloseCoil

    % --- computed
    properties
        matrix
    end

    % --- computed
    properties (Access = private)
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = CloseCoil.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = CloseCoilAphi(args)
            arguments
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
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            setup@CloseCoil(obj);
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
                         obj.matrix.unit_current_field(:,obj.matrix.gid_elem),'sfactor',0.2);
            end
        end
    end

    % --- reset
    methods
        function reset(obj)
            if isprop(obj,'setup_done')
                obj.setup_done = 0;
            end
            if isprop(obj,'build_done')
                obj.build_done = 0;
            end
            if isprop(obj,'assembly_done')
                obj.assembly_done = 0;
            end
        end
    end

end