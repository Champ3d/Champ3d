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

classdef CloseCoil < Coil
    properties
        etrode_equation
        % ---
        electrode_dom
        shape_dom
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom3d','etrode_equation'};
        end
    end
    % --- Contructor
    methods
        function obj = CloseCoil()
            obj@Coil;
        end
    end
    % --- Utility Methods
    methods
        function [unit_current_field,alpha] = get_uj_alpha(obj)
            % ---
            obj.setup;
            % ---
            if obj.build_done
                return
            end
            % ---
            parent_mesh = obj.parent_model.parent_mesh;
            % --- current field
            unit_current_field = zeros(3,parent_mesh.nb_elem);
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
                % --- XTODO
                alpha = [];
            end
        end
    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            % ---
            args4cv3.parent_mesh = obj.parent_model.parent_mesh;
            args4cv3.id_dom3d = obj.id_dom3d;
            args4cv3.cut_equation = obj.etrode_equation;
            % ---
            argu = f_to_namedarg(args4cv3,'for','CutVolumeDom3d');
            % ---
            obj.electrode_dom = CutVolumeDom3d(argu{:});
            % ---
            coilshape = obj.dom - obj.electrode_dom;
            % ---
            % obj.shape_dom = eval(class(obj.electrode_dom));
            % obj.shape_dom <= coilshape;
            obj.shape_dom = coilshape;
            % ---
            obj.shape_dom.gid_side_node_1 = obj.electrode_dom.gid_side_node_2;
            obj.shape_dom.gid_side_node_2 = obj.electrode_dom.gid_side_node_1;
        end
        % -----------------------------------------------------------------
        function plot(obj)
            % ---
            obj.electrode_dom.plot('face_color',f_color(100),'alpha',0.5); hold on;
            % ---
            if isfield(obj.matrix,'unit_current_field')
                if ~isempty(obj.matrix.unit_current_field)
                    f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gid_elem), ...
                             obj.matrix.unit_current_field(:,obj.matrix.gid_elem),'sfactor',0.2);
                end
            end
        end
        % -----------------------------------------------------------------
    end
end