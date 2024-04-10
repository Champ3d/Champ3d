%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThPsTemp < ThPs

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
        function obj = ThPsTemp(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.ps
            end
            % ---
            obj = obj@ThPs;
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
            setup@ThPs(obj);
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
            % ---
            gid_face = dom.gid_face;
            nb_face  = length(gid_face);
            % ---
            gid_node_t = f_uniquenode(dom.parent_mesh.face(:,gid_face));
            % ---
            ps_array = obj.ps.get_on(dom);
            ps_array = obj.column_array(ps_array,'nb_elem',nb_face);
            % ---
            dom.build_submesh;
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face_  = sm.lid_face;
                ps_sm = ps_array(lid_face_);
                pswn{k} = sm.cwn('coefficient',ps_sm);
                % ---
                gid_face_{k} = sm.gid_face;
            end
            % ---
            obj.matrix.gid_node_t = gid_node_t;
            % ---
            obj.matrix.pswn = pswn;
            obj.matrix.gid_face = gid_face_;
            obj.matrix.ps_array = ps_array;
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
            face = obj.parent_model.parent_mesh.face;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            %--------------------------------------------------------------
            pswn = sparse(nb_node,1);
            %--------------------------------------------------------------
            gid_face = obj.matrix.gid_face;
            lmatrix  = obj.matrix.pswn;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbNo_inFa = size(lmatrix{igr},2);
                id_face = gid_face{igr};
                for i = 1:nbNo_inFa
                    pswn = pswn + ...
                        sparse(face(i,id_face),1,lmatrix{igr}(:,i),nb_node,1);
                end
            end
            %--------------------------------------------------------------
            obj.parent_model.matrix.pswn = ...
                obj.parent_model.matrix.pswn + pswn;
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