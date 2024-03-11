%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PMagnetAphi < PMagnet

    % --- computed
    properties
        build_done = 0
        matrix
    end

    % --- Contructor
    methods
        function obj = PMagnetAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.br
            end
            % ---
            obj = obj@PMagnet;
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
                setup@PMagnet(obj);
                % ---
                if isnumeric(obj.br)
                    obj.br = Parameter('f',obj.br);
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
            br = obj.br.get_on(dom);
            wfbr = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',br);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.wfbr = wfbr;
            % ---
            obj.build_done = 1;
        end
    end
end