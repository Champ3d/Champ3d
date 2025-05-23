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

classdef ThPv < PhysicalDom
    properties
        pv = 0
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','pv','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = ThPv(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.pv
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
            ThPv.setup(obj);
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
            obj.matrix.gindex = [];
            obj.matrix.gid_node_t = [];
            obj.matrix.pv_array = [];
            obj.matrix.pvwn = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            ThPv.setup(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gindex = dom.gindex;
            % ---
            elem = parent_mesh.elem(:,gindex);
            % ---
            gid_node_t = f_uniquenode(elem);
            % ---
            pv_array = obj.pv.getvalue('in_dom',obj);
            % --- save
            % it = obj.parent_model.ltime.it;
            %obj.field{it}.pv.elem = FreeScalarElemField('parent_model',obj,'dof',obj.dof{it}.T,...
            %    'reference_potential',obj.T0);
            %pv_array;
            % --- check changes
            is_changed = 1;
            if isequal(pv_array,obj.matrix.pv_array) && ...
               isequal(gindex,obj.matrix.gindex) && ...
               isequal(gid_node_t,obj.matrix.gid_node_t)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gindex = gindex;
            obj.matrix.gid_node_t = gid_node_t;
            obj.matrix.pv_array = pv_array;
            %--------------------------------------------------------------
            % local pvwn matrix
            % ---
            lmatrix = parent_mesh.cwn('id_elem',gindex,'coefficient',pv_array);
            %--------------------------------------------------------------
            id_elem_nomesh = obj.parent_model.matrix.id_elem_nomesh;
            elem = obj.parent_model.parent_mesh.elem;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            nbNo_inEl = obj.parent_model.parent_mesh.refelem.nbNo_inEl;
            %--------------------------------------------------------------
            gindex = obj.matrix.gindex;
            %--------------------------------------------------------------
            [~,id_] = intersect(gindex,id_elem_nomesh);
            gindex(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
            % global elementary pvwn matrix
            pvwn = sparse(nb_node,1);
            %--------------------------------------------------------------
            for i = 1:nbNo_inEl
                pvwn = pvwn + ...
                    sparse(elem(i,gindex),1,lmatrix(:,i),nb_node,1);
            end
            %--------------------------------------------------------------
            obj.matrix.pvwn = pvwn;
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
            obj.parent_model.matrix.pvwn = ...
                obj.parent_model.matrix.pvwn + obj.matrix.pvwn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end