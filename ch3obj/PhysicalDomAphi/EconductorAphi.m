%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef EconductorAphi < Econductor

    % --- computed
    properties
        matrix = struct('gid_elem',[],'gid_node_phi',[],'sigmawewe',[],'sigma_array',[])
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = Econductor.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = EconductorAphi(args)
            arguments
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
            EconductorAphi.setup(obj);
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
            setup@Econductor(obj);
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
            reset@Econductor(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            EconductorAphi.setup(obj);
            % ---
            build@Econductor(obj);
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
            sigma_array = obj.sigma.get('in_dom',dom);
            % ---
            sigmawewe = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.gid_node_phi = gid_node_phi;
            obj.matrix.sigmawewe = sigmawewe;
            obj.matrix.sigma_array = sigma_array;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@Econductor(obj);
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