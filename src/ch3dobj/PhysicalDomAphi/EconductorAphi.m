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
        build_done = 0
        matrix
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
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            if ~obj.setup_done
                % ---
                setup@Econductor(obj);
                % ---
                if isnumeric(obj.sigma)
                    obj.sigma = Parameter('f',obj.sigma);
                end
                % ---
                obj.setup_done = 1;
                % ---
                obj.build_done = 0;
            end
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
        end
    end
end