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
        matrix
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
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
            if obj.setup_done
                return
            end
            % ---
            setup@Bsfield(obj);
            % ---
            obj.setup_done = 1;
            % ---
            obj.build_done = 0;
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

    % --- assembly
    methods
        function assembly(obj)
            a_bsfield = zeros(nb_edge,1);
            for iec = 1:length(id_bsfield__)
                %----------------------------------------------------------------------
                wfbs = sparse(nb_face,1);
                %----------------------------------------------------------------------
                id_phydom = id_bsfield__{iec};
                %----------------------------------------------------------------------
                f_fprintf(0,'--- #bsfield',1,id_phydom,0,'\n');
                %----------------------------------------------------------------------
                id_elem = obj.bsfield.(id_phydom).matrix.gid_elem;
                lmatrix = obj.bsfield.(id_phydom).matrix.wfbs;
                for i = 1:nbFa_inEl
                    wfbs = wfbs + ...
                        sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
                end
                %----------------------------------------------------------------------
                rotb = obj.parent_mesh.discrete.rot.' * wfbs;
                rotrot = obj.parent_mesh.discrete.rot.' * ...
                    obj.matrix.wfwf * ...
                    obj.parent_mesh.discrete.rot;
                %----------------------------------------------------------------------
                id_edge_a_unknown = obj.matrix.id_edge_a;
                %----------------------------------------------------------------------
                rotb = rotb(id_edge_a_unknown,1);
                rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
                %----------------------------------------------------------------------
                int_oned_a = zeros(nb_edge,1);
                int_oned_a(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
                clear rotb rotrot
                %----------------------------------------------------------------------
                a_bsfield = a_bsfield + int_oned_a;
            end
            %--------------------------------------------------------------------------
            obj.dof.a_bs = a_bsfield;
            obj.dof.bs   = obj.parent_mesh.discrete.rot * a_bsfield;
        end
    end
end