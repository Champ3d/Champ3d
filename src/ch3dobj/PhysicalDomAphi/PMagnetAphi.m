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
            setup@PMagnet(obj);
            % ---
            if isnumeric(obj.br)
                obj.br = Parameter('f',obj.br);
            end
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
            br = obj.br.get_on(dom);
            wfbr = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',br);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.wfbr = wfbr;
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
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            nb_face = obj.parent_model.parent_mesh.nb_face;
            id_face_in_elem = obj.parent_model.parent_mesh.meshds.id_face_in_elem;
            nbFa_inEl = obj.parent_model.parent_mesh.refelem.nbFa_inEl;
            %--------------------------------------------------------------
            wfbr = sparse(nb_face,1);
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            lmatrix  = obj.matrix.wfbr;
            for i = 1:nbFa_inEl
                wfbr = wfbr + ...
                    sparse(id_face_in_elem(i,gid_elem),1,lmatrix(:,i),nb_face,1);
            end
            %--------------------------------------------------------------
            rotb = obj.parent_model.parent_mesh.discrete.rot.' * wfbr;
            rotrot = obj.parent_model.parent_mesh.discrete.rot.' * ...
                     obj.parent_model.matrix.wfwf * ...
                     obj.parent_model.parent_mesh.discrete.rot;
            %--------------------------------------------------------------
            id_edge_a_unknown = obj.parent_model.matrix.id_edge_a;
            %--------------------------------------------------------------
            rotb = rotb(id_edge_a_unknown,1);
            rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
            %--------------------------------------------------------------
            a_pmagnet = sparse(nb_edge,1);
            a_pmagnet(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
            clear rotb rotrot wfbr
            %--------------------------------------------------------------
            obj.parent_model.dof.a_pm = ...
                obj.parent_model.dof.a_pm + a_pmagnet;
            %--------------------------------------------------------------
            %obj.parent_model.dof.bpm  = ...
            %    obj.parent_model.dof.bpm + ...
            %    obj.parent_model.parent_mesh.discrete.rot * a_pmagnet;
            %--------------------------------------------------------------
            obj.assembly_done = 1;
        end
    end
end