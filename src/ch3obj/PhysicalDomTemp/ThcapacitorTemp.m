%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThcapacitorTemp < Thcapacitor

    % --- computed
    properties
        matrix
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end

    % --- Contructor
    methods
        function obj = ThcapacitorTemp(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.rho
                args.cp
            end
            % ---
            obj = obj@Thcapacitor;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_done = 0;
            obj.build_done = 0;
            obj.assembly_done = 0;
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
            setup@Thcapacitor(obj);
            % ---
            obj.setup_done = 1;
            % ---
            obj.build_done = 0;
            obj.assembly_done = 0;
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
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gid_elem = dom.gid_elem;
            % ---
            elem = parent_mesh.elem(:,gid_elem);
            % ---
            gid_node_t = f_uniquenode(elem);
            % ---
            rho_array = obj.rho.get_on(dom);
            cp_array  = obj.cp.get_on(dom);
            rho_cp_array = rho_array .* cp_array;
            % ---
            rhocpwnwn = parent_mesh.cwnwn('id_elem',gid_elem,'coefficient',rho_cp_array);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_t = gid_node_t;
            obj.matrix.rhocpwnwn = rhocpwnwn;
            obj.matrix.rho_array = rho_array;
            obj.matrix.cp_array = cp_array;
            obj.matrix.rho_cp_array = rho_cp_array;
            % ---
            obj.build_done = 1;
            obj.assembly_done = 0;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            % ---
            if obj.assembly_done
                return
            end
            %--------------------------------------------------------------
            id_elem_nomesh = obj.parent_model.matrix.id_elem_nomesh;
            elem = obj.parent_model.parent_mesh.elem;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            nbNo_inEl = obj.parent_model.parent_mesh.refelem.nbNo_inEl;
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            lmatrix = obj.matrix.rhocpwnwn;
            %--------------------------------------------------------------
            [~,id_] = intersect(gid_elem,id_elem_nomesh);
            gid_elem(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
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
            obj.parent_model.matrix.rhocpwnwn = ...
                obj.parent_model.matrix.rhocpwnwn + rhocpwnwn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
            obj.assembly_done = 1;
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