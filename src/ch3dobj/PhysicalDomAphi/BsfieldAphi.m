%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef BsfieldAphi < Bsfield

    % --- computed
    properties
        build_done = 0
        matrix
    end

    % --- Contructor
    methods
        function obj = BsfieldAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.bs
            end
            % ---
            obj = obj@Bsfield;
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
                setup@Bsfield(obj);
                % ---
                if isnumeric(obj.bs)
                    obj.bs = Parameter('f',obj.bs);
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
            bs = obj.bs.get_on(dom);
            wfbs = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',bs);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.wfbs = wfbs;
            % ---
            obj.build_done = 1;
        end
    end
end