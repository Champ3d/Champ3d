%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThcapacitorTherm < Thcapacitor

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
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = Thcapacitor.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = ThcapacitorTherm(args)
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
            ThcapacitorTherm.setup(obj);
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
            setup@Thcapacitor(obj);
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
            reset@Thcapacitor(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            ThcapacitorTherm.setup(obj);
            % ---
            build@Thcapacitor(obj);
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
            rho_array = obj.rho.get('in_dom',dom);
            cp_array  = obj.cp.get('in_dom',dom);
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
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@Thcapacitor(obj);
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
end