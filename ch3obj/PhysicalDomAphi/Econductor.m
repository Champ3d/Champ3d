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

classdef Econductor < PhysicalDom
    properties
        sigma
        % ---
        matrix
        tarray
    end
    % ---
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','sigma','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Econductor(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.sigma
                args.parameter_dependency_search ...
                    {mustBeMember(args.parameter_dependency_search,{'by_coordinates','by_id_dom'})} ...
                    = 'by_id_dom'
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Econductor.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.gid_node_phi = [];
            obj.matrix.sigmawewe = [];
            obj.matrix.sigma_array = [];
            obj.tarray = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Econductor.setup(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            it = obj.parent_model.ltime.it;
            % ---
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gid_elem = dom.gid_elem;
            % ---
            elem = parent_mesh.elem(:,gid_elem);
            % ---
            gid_node_phi = f_uniquenode(elem);
            % ---
            sigma_array = obj.sigma.getvalue('in_dom',dom);
            % --- check changes
            is_changed = 1;
            % if isequal(sigma_array,obj.matrix.sigma_array{it}) && ...
            %    isequal(gid_elem,obj.matrix.gid_elem) && ...
            %    isequal(gid_node_phi,obj.matrix.gid_node_phi)
            %     is_changed = 0;
            % end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_phi = gid_node_phi;
            obj.matrix.sigma_array{it} = sigma_array;
            % obj.tarray{it}.sigma = TensorArray('');
            %--------------------------------------------------------------
            % local sigmawewe matrix
            lmatrix = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
            %--------------------------------------------------------------
            id_elem_nomesh = obj.parent_model.matrix.id_elem_nomesh;
            id_edge_in_elem = obj.parent_model.parent_mesh.meshds.id_edge_in_elem;
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            nbEd_inEl = obj.parent_model.parent_mesh.refelem.nbEd_inEl;
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            %--------------------------------------------------------------
            [~,id_] = intersect(gid_elem,id_elem_nomesh);
            gid_elem(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
            % global elementary sigmawewe matrix
            sigmawewe = sparse(nb_edge,nb_edge);
            %--------------------------------------------------------------
            for i = 1:nbEd_inEl
                for j = i+1 : nbEd_inEl
                    sigmawewe = sigmawewe + ...
                        sparse(id_edge_in_elem(i,gid_elem),id_edge_in_elem(j,gid_elem),...
                        lmatrix(:,i,j),nb_edge,nb_edge);
                end
            end
            % ---
            sigmawewe = sigmawewe + sigmawewe.';
            % ---
            for i = 1:nbEd_inEl
                sigmawewe = sigmawewe + ...
                    sparse(id_edge_in_elem(i,gid_elem),id_edge_in_elem(i,gid_elem),...
                    lmatrix(:,i,i),nb_edge,nb_edge);
            end
            %--------------------------------------------------------------
            obj.matrix.sigmawewe = sigmawewe;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.sigmawewe = ...
                obj.parent_model.matrix.sigmawewe + obj.matrix.sigmawewe;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_phi = ...
                unique([obj.parent_model.matrix.id_node_phi, obj.matrix.gid_node_phi]);
            %--------------------------------------------------------------
        end
    end

    % --- postpro
    methods
        function postpro(obj)
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            sigma_array = obj.matrix.sigma_array;
            %--------------------------------------------------------------
            [coef, coef_array_type] = f_column_format(sigma_array);
            %--------------------------------------------------------------
            ev = obj.parent_model.field.ev(:,gid_elem);
            jv = zeros(3,length(gid_elem));
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                jv = coef .* ev;
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                jv(1,:) = coef(:,1,1).' .* ev(1,:) + ...
                          coef(:,1,2).' .* ev(2,:) + ...
                          coef(:,1,3).' .* ev(3,:);
                jv(2,:) = coef(:,2,1).' .* ev(1,:) + ...
                          coef(:,2,2).' .* ev(2,:) + ...
                          coef(:,2,3).' .* ev(3,:);
                jv(3,:) = coef(:,3,1).' .* ev(1,:) + ...
                          coef(:,3,2).' .* ev(2,:) + ...
                          coef(:,3,3).' .* ev(3,:);
            end
            %--------------------------------------------------------------
            obj.parent_model.field.jv(:,gid_elem) = jv;
            %--------------------------------------------------------------
            obj.parent_model.field.pv(:,gid_elem) = ...
                real(1/2 .* sum(ev .* conj(jv)));
            %--------------------------------------------------------------
        end
    end
end