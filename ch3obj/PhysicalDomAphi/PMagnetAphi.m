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
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = PMagnet.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = PMagnetAphi(args)
            arguments
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
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            setup@PMagnet(obj);
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
            br = obj.br.get('in_dom',dom);
            wfbr = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',br);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.wfbr = wfbr;
            obj.matrix.br = br;
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
            a_pmagnet = zeros(nb_edge,1);
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

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'k'
                args.face_color = 'none'
                args.alpha {mustBeNumeric} = 0.5
            end
            % ---
            argu = f_to_namedarg(args);
            plot@PMagnet(obj,argu{:});
            % ---
            if isfield(obj.matrix,'br')
                if ~isempty(obj.matrix.br)
                    hold on;
                    f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gid_elem), ...
                             obj.matrix.br(:,obj.matrix.gid_elem).','sfactor',0.2);
                end
            end
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