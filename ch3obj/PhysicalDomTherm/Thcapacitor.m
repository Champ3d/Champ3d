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

classdef Thcapacitor < PhysicalDom
    properties
        rho = 0
        cp  = 0
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','rho','cp','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Thcapacitor(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.rho
                args.cp
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
            Thcapacitor.setup(obj);
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
            obj.matrix.rho_array = [];
            obj.matrix.cp_array = [];
            obj.matrix.rho_cp_array = [];
            obj.matrix.rhocpwnwn = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Thcapacitor.setup(obj);
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
            rho_array = obj.rho.getvalue('in_dom',obj);
            cp_array  = obj.cp.getvalue('in_dom',obj);
            rho_cp_array = rho_array .* cp_array;
            % --- check changes
            is_changed = 1;
            if isequal(rho_cp_array,obj.matrix.rho_cp_array) && ...
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
            % ---
            obj.matrix.rho_array = rho_array;
            obj.matrix.cp_array = cp_array;
            obj.matrix.rho_cp_array = rho_cp_array;
            %--------------------------------------------------------------
            % local rhocpwnwn matrix
            lmatrix = parent_mesh.cwnwn('id_elem',gindex,'coefficient',rho_cp_array);
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
            % global elementary rhocpwnwn matrix
            rhocpwnwn = sparse(nb_node,nb_node);
            %--------------------------------------------------------------
            for i = 1:nbNo_inEl
                for j = i+1 : nbNo_inEl
                    rhocpwnwn = rhocpwnwn + ...
                        sparse(elem(i,gindex),elem(j,gindex),...
                        lmatrix(:,i,j),nb_node,nb_node);
                end
            end
            % ---
            rhocpwnwn = rhocpwnwn + rhocpwnwn.';
            % ---
            for i = 1:nbNo_inEl
                rhocpwnwn = rhocpwnwn + ...
                    sparse(elem(i,gindex),elem(i,gindex),...
                    lmatrix(:,i,i),nb_node,nb_node);
            end
            %--------------------------------------------------------------
            obj.matrix.rhocpwnwn = rhocpwnwn;
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
            obj.parent_model.matrix.rhocpwnwn = ...
                obj.parent_model.matrix.rhocpwnwn + obj.matrix.rhocpwnwn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end