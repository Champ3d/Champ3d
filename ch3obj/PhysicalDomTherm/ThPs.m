%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThPs < PhysicalDom

    % --- computed
    properties
        ps = 0
        matrix
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','ps'};
        end
    end
    % --- Contructor
    methods
        function obj = ThPs(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.ps
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            ThPs.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_face = [];
            obj.matrix.gid_node_t = [];
            obj.matrix.ps_array = [];
            obj.matrix.pswn = [];
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            obj.setup_done = 0;
            ThPs.setup(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            % ---
            gid_face = dom.gid_face;
            nb_face  = length(gid_face);
            % ---
            gid_node_t = f_uniquenode(dom.parent_mesh.face(:,gid_face));
            % ---
            ps_array = obj.ps.getvalue('in_dom',dom);
            ps_array = f_column_array(ps_array,'nb_elem',nb_face);
            %--------------------------------------------------------------
            % local surface mesh
            submesh = dom.submesh;
            %--------------------------------------------------------------
            for k = 1:length(submesh)
                sm = submesh{k};
                % ---
                gid_face_{k} = sm.gid_face;
            end
            % --- check changes
            is_changed = 1;
            if isequal(ps_array,obj.matrix.ps_array)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_face = gid_face_;
            obj.matrix.gid_node_t = gid_node_t;
            obj.matrix.ps_array = ps_array;
            %--------------------------------------------------------------
            % local pswn matrix
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face_  = sm.lid_face;
                ps_sm = ps_array(lid_face_);
                lmatrix{k} = sm.cwn('coefficient',ps_sm);
                % ---
            end
            %--------------------------------------------------------------
            face = obj.parent_model.parent_mesh.face;
            nb_node = obj.parent_model.parent_mesh.nb_node;
            %--------------------------------------------------------------
            % global elementary pswn matrix
            pswn = sparse(nb_node,1);
            %--------------------------------------------------------------
            gid_face = obj.matrix.gid_face;
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
            obj.matrix.pswn = pswn;
            % ---
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.pswn = ...
                obj.parent_model.matrix.pswn + obj.matrix.pswn;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_t = ...
                [obj.parent_model.matrix.id_node_t obj.matrix.gid_node_t];
            %--------------------------------------------------------------
        end
    end
end