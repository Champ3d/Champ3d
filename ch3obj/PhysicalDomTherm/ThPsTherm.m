%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThPsTherm < ThPs

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
            argslist = ThPs.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = ThPsTherm(args)
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
            ThPsTherm.setup(obj);
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
            setup@ThPs(obj);
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
            reset@ThPs(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            ThPsTherm.setup(obj);
            % ---
            build@ThPs(obj);
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
            ps_array = obj.ps.get('in_dom',dom);
            ps_array = f_column_array(ps_array,'nb_elem',nb_face);
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
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@ThPs(obj);
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
        end
    end
end