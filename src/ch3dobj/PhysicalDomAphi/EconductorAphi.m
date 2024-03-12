%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef EconductorAphi < Econductor

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
        function obj = EconductorAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.sigma
            end
            % ---
            obj = obj@Econductor;
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
            setup@Econductor(obj);
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
            gid_node_phi = f_uniquenode(elem);
            % ---
            sigma_array = obj.sigma.get_on(dom);
            % ---
            sigmawewe = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_phi = gid_node_phi;
            obj.matrix.sigmawewe = sigmawewe;
            obj.matrix.sigma_array = sigma_array;
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
            id_edge_in_elem = obj.parent_model.parent_mesh.meshds.id_edge_in_elem;
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            nbEd_inEl = obj.parent_model.parent_mesh.refelem.nbEd_inEl;
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            lmatrix = obj.matrix.sigmawewe;
            %--------------------------------------------------------------
            [~,id_] = intersect(gid_elem,id_elem_nomesh);
            gid_elem(id_) = [];
            lmatrix(id_,:,:) = [];
            %--------------------------------------------------------------
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
            obj.parent_model.matrix.sigmawewe = ...
                obj.parent_model.matrix.sigmawewe + sigmawewe;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_phi = ...
                [obj.parent_model.matrix.id_node_phi obj.matrix.gid_node_phi];
            %--------------------------------------------------------------
            obj.assembly_done = 1;
        end
    end
end