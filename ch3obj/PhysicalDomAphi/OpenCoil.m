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

classdef OpenCoil < Coil
    properties
        etrode_equation
        % ---
        gid_node_petrode
        gid_node_netrode
        % ---
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom3d','etrode_equation'};
        end
    end
    % --- Contructor
    methods
        function obj = OpenCoil()
            obj@Coil;
        end
    end
    % --- Utility Methods
    methods
        function [unit_current_field,alpha,dofuJ] = get_uj_alpha(obj)
            % ---
            parent_mesh = obj.parent_model.parent_mesh;
            % --- current field
            unit_current_field = zeros(parent_mesh.nb_elem,3);
            % ---
            nbEd_inEl = parent_mesh.refelem.nbEd_inEl;
            % ---
            nb_node = parent_mesh.nb_node;
            nb_edge = parent_mesh.nb_edge;
            id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
            % ---
            vdom = obj.dom;
            % ---
            gindex = vdom.gindex;
            gid_node_vdom = f_uniquenode(parent_mesh.elem(:,vdom.gindex));
            lwewe = parent_mesh.cwewe('id_elem',gindex);
            % ---
            gwewe = sparse(nb_edge,nb_edge);
            for j = 1:nbEd_inEl
                for k = j+1 : nbEd_inEl
                    gwewe = gwewe + ...
                        sparse(id_edge_in_elem(j,gindex),id_edge_in_elem(j,gindex),...
                        lwewe(:,j,k),nb_edge,nb_edge);
                end
            end
            gwewe = gwewe + gwewe.';
            for j = 1:nbEd_inEl
                gwewe = gwewe + ...
                    sparse(id_edge_in_elem(j,gindex),id_edge_in_elem(j,gindex),...
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
                V(id_node_v_unknown) = gradgrad \ RHS;
            end
            % ---
            dofuJ = - parent_mesh.discrete.grad * V;
            vJs = parent_mesh.field_we('dof',dofuJ,'id_elem',gindex);
            vJs = Array.normalize(vJs);
            % ---
            unit_current_field = unit_current_field + vJs;
            % ---
            alpha = V;
            % ---
        end
    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            % ---
            parent_mesh = obj.parent_model.parent_mesh;
            etrode_eq = obj.etrode_equation;
            id_dom3d = f_to_scellargin(obj.id_dom3d);
            id_dom3d = id_dom3d{1};
            % ---
            gindex = parent_mesh.dom.(id_dom3d).gindex;
            boface = f_boundface(parent_mesh.elem(:,gindex),...
               parent_mesh.node,'elem_type',parent_mesh.elem_type);
            % ---
            gid_node = f_uniquenode(boface);
            % ---
            bonode = parent_mesh.node(:,gid_node);
            % ---
            petrode = [];
            netrode = [];
            for i = 1:length(etrode_eq)
                condi = etrode_eq{i};
                lid_node = f_findnode(bonode,'condition',condi);
                if i == 1
                    petrode = lid_node;
                    % ---
                    if isempty(petrode)
                        warning(['Electrode not found from eq ' etrode_eq{i}]);
                    end
                else
                    netrode = [netrode lid_node];
                    % ---
                    if isempty(netrode)
                        warning(['Electrode not found from eq ' etrode_eq{i}]);
                    end
                end
            end
            % -------------------------------------------------------------
            obj.gid_node_petrode = unique(gid_node(petrode));
            obj.gid_node_netrode = unique(gid_node(netrode));
        end
        % -----------------------------------------------------------------
        function plot(obj)
            % ---
            penode = obj.parent_model.parent_mesh.node(:,obj.gid_node_petrode);
            nenode = obj.parent_model.parent_mesh.node(:,obj.gid_node_netrode);
            if size(penode,1) == 2
                plot(penode(1,:),penode(2,:),'ro'); hold on
                plot(nenode(1,:),nenode(2,:),'bo'); hold on
            elseif size(penode,1) == 3
                plot3(penode(1,:),penode(2,:),penode(3,:),'ro'); hold on
                plot3(nenode(1,:),nenode(2,:),nenode(3,:),'bo'); hold on
            end
            % ---
            if isfield(obj.matrix,'unit_current_field')
                if ~isempty(obj.matrix.unit_current_field)
                    f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gindex), ...
                             obj.matrix.unit_current_field(:,obj.matrix.gindex),'sfactor',0.2);
                end
            end
        end
        % -----------------------------------------------------------------
    end
end