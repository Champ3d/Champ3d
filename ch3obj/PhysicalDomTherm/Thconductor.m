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

classdef Thconductor < PhysicalDom
    properties
        lambda = 0
        % ---
        matrix
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','lambda','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Thconductor(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.lambda
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
            Thconductor.setup(obj);
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
            obj.matrix.gid_node_t = [];
            obj.matrix.lambda_array = [];
            obj.matrix.lambdawewe = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Thconductor.setup(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gid_elem = dom.gid_elem;
            % ---
            elem = parent_mesh.elem(:,gid_elem);
            % ---
            gid_node_t = f_uniquenode(elem);
            % ---
            lambda_array = obj.lambda.getvalue('in_dom',obj);
            % --- check changes
            is_changed = 1;
            if isequal(lambda_array,obj.matrix.lambda_array)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_t = gid_node_t;
            obj.matrix.lambda_array = lambda_array;
            %--------------------------------------------------------------
            % local lambdawewe matrix
            lmatrix = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',lambda_array);
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
            % global elementary lambdawewe matrix
            lambdawewe = sparse(nb_edge,nb_edge);
            %--------------------------------------------------------------
            for i = 1:nbEd_inEl
                for j = i+1 : nbEd_inEl
                    lambdawewe = lambdawewe + ...
                        sparse(id_edge_in_elem(i,gid_elem),id_edge_in_elem(j,gid_elem),...
                        lmatrix(:,i,j),nb_edge,nb_edge);
                end
            end
            % ---
            lambdawewe = lambdawewe + lambdawewe.';
            % ---
            for i = 1:nbEd_inEl
                lambdawewe = lambdawewe + ...
                    sparse(id_edge_in_elem(i,gid_elem),id_edge_in_elem(i,gid_elem),...
                    lmatrix(:,i,i),nb_edge,nb_edge);
            end
            %--------------------------------------------------------------
            obj.matrix.lambdawewe = lambdawewe;
            % ---
            obj.build_done = 1;
            % ---
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.lambdawewe = ...
                obj.parent_model.matrix.lambdawewe + obj.matrix.lambdawewe;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end