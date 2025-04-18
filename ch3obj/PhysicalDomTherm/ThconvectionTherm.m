%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThconvectionTherm < Thconvection

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
            argslist = Thconvection.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = ThconvectionTherm(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.h
            end
            % ---
            obj = obj@Thconvection;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            ThconvectionTherm.setup(obj);
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
            setup@Thconvection(obj);
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
            reset@Thconvection(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            ThconvectionTherm.setup(obj);
            % ---
            build@Thconvection(obj);
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
            h_array = obj.h.get('in_dom',dom);
            h_array = f_column_array(h_array,'nb_elem',nb_face);
            % ---
            dom.build_submesh;
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face_  = sm.lid_face;
                h_sm = h_array(lid_face_);
                hwnwn{k} = sm.cwnwn('coefficient',h_sm);
                % ---
                gid_face_{k} = sm.gid_face;
            end
            % ---
            obj.matrix.gid_node_t = gid_node_t;
            % ---
            obj.matrix.hwnwn = hwnwn;
            obj.matrix.gid_face = gid_face_;
            obj.matrix.h_array = h_array;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@Thconvection(obj);
            %--------------------------------------------------------------
            face = obj.parent_model.parent_mesh.face;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            %--------------------------------------------------------------
            hwnwn = sparse(nb_node,nb_node);
            %--------------------------------------------------------------
            gid_face = obj.matrix.gid_face;
            lmatrix  = obj.matrix.hwnwn;
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                nbNo_inFa = size(lmatrix{igr},2);
                id_face = gid_face{igr};
                for i = 1:nbNo_inFa
                    for j = i+1 : nbNo_inFa
                        hwnwn = hwnwn + ...
                            sparse(face(i,id_face),face(j,id_face),...
                            lmatrix{igr}(:,i,j),nb_node,nb_node);
                    end
                end
            end
            %--------------------------------------------------------------
            hwnwn = hwnwn + hwnwn.';
            %--------------------------------------------------------------
            for igr = 1:length(lmatrix)
                id_face = gid_face{igr};
                nbNo_inFa = size(lmatrix{igr},2);
                for i = 1:nbNo_inFa
                    hwnwn = hwnwn + ...
                        sparse(face(i,id_face),face(i,id_face),...
                        lmatrix{igr}(:,i,i),nb_node,nb_node);
                end
            end
            %--------------------------------------------------------------
            obj.parent_model.matrix.hwnwn = ...
                obj.parent_model.matrix.hwnwn + hwnwn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end