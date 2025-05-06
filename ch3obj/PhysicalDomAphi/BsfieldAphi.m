%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
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
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = Bsfield.validargs;
        end
    end
    % --- Contructor
    methods
        function obj = BsfieldAphi(args)
            arguments
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
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            setup@Bsfield(obj);
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
            if isa(obj.bs,'Parameter')
                bs = obj.bs.getvalue('in_dom',dom);
            elseif iscell(obj.bs)
                bs = obj.bs;
            end
            % ---
            wfbs = parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',bs);
            % ---
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.wfbs = wfbs;
            % ---
            if iscell(obj.bs)
                bs = 0;
                for i = 1:length(obj.bs)
                    bs = bs + obj.bs{i};
                end
                bs = bs ./ length(obj.bs);
            end
            obj.matrix.bs = bs;
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
            wfbs = sparse(nb_face,1);
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            lmatrix  = obj.matrix.wfbs;
            for i = 1:nbFa_inEl
                wfbs = wfbs + ...
                    sparse(id_face_in_elem(i,gid_elem),1,lmatrix(:,i),nb_face,1);
            end
            %--------------------------------------------------------------
            rotb = obj.parent_model.parent_mesh.discrete.rot.' * wfbs;
            rotrot = obj.parent_model.parent_mesh.discrete.rot.' * ...
                     obj.parent_model.matrix.wfwf * ...
                     obj.parent_model.parent_mesh.discrete.rot;
            %--------------------------------------------------------------
            id_edge_a_unknown = obj.parent_model.matrix.id_edge_a;
            %--------------------------------------------------------------
            rotb = rotb(id_edge_a_unknown,1);
            rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
            %--------------------------------------------------------------
            a_bsfield = zeros(nb_edge,1);
            a_bsfield(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
            %--------------------------------------------------------------
            clear rotb rotrot wfbs
            %--------------------------------------------------------------
            obj.parent_model.dof.a_bs = ...
                obj.parent_model.dof.a_bs + a_bsfield;
            %--------------------------------------------------------------
            %obj.parent_model.dof.bs   = ...
            %    obj.parent_model.dof.bs + ...
            %    obj.parent_model.parent_mesh.discrete.rot * a_bsfield;
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
            plot@CloseCoil(obj,argu{:});
            % ---
            if ~isempty(obj.matrix.bs)
                hold on;
                f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gid_elem), ...
                         obj.matrix.bs(:,obj.matrix.gid_elem).','sfactor',0.2);
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