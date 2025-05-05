%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Thcapacitor < PhysicalDom

    % --- computed
    properties
        rho = 0
        cp  = 0
        matrix
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','rho','cp','parameter_dependency_search'};
        end
    end
    % --- Contructor
    methods
        function obj = Thcapacitor(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
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
            % ---
            if obj.setup_done
                return
            end
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.gid_node_t = [];
            obj.matrix.rho_array = [];
            obj.matrix.cp_array = [];
            obj.matrix.rho_cp_array = [];
            obj.matrix.rhocpwnwn = [];
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            obj.setup_done = 0;
            Thcapacitor.setup(obj);
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
            rho_array = obj.rho.getvalue('in_dom',obj);
            cp_array  = obj.cp.getvalue('in_dom',obj);
            rho_cp_array = rho_array .* cp_array;
            % --- check changes
            is_changed = 1;
            if isequal(rho_cp_array,obj.matrix.rho_cp_array)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_t = gid_node_t;
            % ---
            obj.matrix.rho_array = rho_array;
            obj.matrix.cp_array = cp_array;
            obj.matrix.rho_cp_array = rho_cp_array;
            %--------------------------------------------------------------
            % local rhocpwnwn matrix
            lmatrix = parent_mesh.cwnwn('id_elem',gid_elem,'coefficient',rho_cp_array);
            %--------------------------------------------------------------
            id_elem_nomesh = obj.parent_model.matrix.id_elem_nomesh;
            elem = obj.parent_model.parent_mesh.elem;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            nbNo_inEl = obj.parent_model.parent_mesh.refelem.nbNo_inEl;
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            %--------------------------------------------------------------
            [~,id_] = intersect(gid_elem,id_elem_nomesh);
            gid_elem(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
            % global elementary rhocpwnwn matrix
            rhocpwnwn = sparse(nb_node,nb_node);
            %--------------------------------------------------------------
            for i = 1:nbNo_inEl
                for j = i+1 : nbNo_inEl
                    rhocpwnwn = rhocpwnwn + ...
                        sparse(elem(i,gid_elem),elem(j,gid_elem),...
                        lmatrix(:,i,j),nb_node,nb_node);
                end
            end
            % ---
            rhocpwnwn = rhocpwnwn + rhocpwnwn.';
            % ---
            for i = 1:nbNo_inEl
                rhocpwnwn = rhocpwnwn + ...
                    sparse(elem(i,gid_elem),elem(i,gid_elem),...
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