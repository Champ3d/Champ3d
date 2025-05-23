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

classdef PMagnet < PhysicalDom
    properties
        br
    end
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','br'};
        end
    end
    % --- Contructor
    methods
        function obj = PMagnet(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.br
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
            PMagnet.setup(obj);
            % ---
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gindex = [];
            obj.matrix.wfbr = [];
            obj.matrix.br_array = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            parent_mesh = dom.parent_mesh;
            gindex = dom.gindex;
            % ---
            br_array = obj.br.getvalue('in_dom',dom);
            % --- check changes
            is_changed = 1;
            if isequal(br_array,obj.matrix.br_array) && ...
               isequal(gindex,obj.matrix.gindex)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gindex = gindex;
            obj.matrix.br_array = br_array;
            %--------------------------------------------------------------
            % local wfbs matrix
            lmatrix = parent_mesh.cwfvf('id_elem',gindex,'vector_field',br_array);
            %--------------------------------------------------------------
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            nb_face = obj.parent_model.parent_mesh.nb_face;
            id_face_in_elem = obj.parent_model.parent_mesh.meshds.id_face_in_elem;
            nbFa_inEl = obj.parent_model.parent_mesh.refelem.nbFa_inEl;
            %--------------------------------------------------------------
            % global elementary wfbs matrix
            wfbr = sparse(nb_face,1);
            %--------------------------------------------------------------
            gindex = obj.matrix.gindex;
            for i = 1:nbFa_inEl
                wfbr = wfbr + ...
                    sparse(id_face_in_elem(i,gindex),1,lmatrix(:,i),nb_face,1);
            end
            %--------------------------------------------------------------
            rotb = obj.parent_model.parent_mesh.discrete.rot.' * wfbr;
            rotrot = obj.parent_model.parent_mesh.discrete.rot.' * ...
                     obj.parent_model.matrix.wfwf * ...
                     obj.parent_model.parent_mesh.discrete.rot;
            %--------------------------------------------------------------
            % id_edge_a_unknown = obj.parent_model.matrix.id_edge_a;
            % rotb = rotb(id_edge_a_unknown,1);
            % rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
            % a_pmagnet = zeros(nb_edge,1);
            % a_pmagnet(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
            %--------------------------------------------------------------
            % --- qmr + jacobi
            M = sqrt(diag(diag(rotrot)));
            [a_pm,flag,relres,niter,resvec] = qmr(rotrot, rotb, 1e-6, 5e3, M.', M);
            %--------------------------------------------------------------
            obj.matrix.wfbr = wfbr;
            obj.matrix.a_pm = a_pm;
            % ---
            obj.build_done = 1;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.a_pm = ...
                obj.parent_model.matrix.a_pm + obj.matrix.a_pm;
            %--------------------------------------------------------------
            %obj.parent_model.matrix.bpm  = ...
            %    obj.parent_model.matrix.bpm + ...
            %    obj.parent_model.parent_mesh.discrete.rot * obj.matrix.a_pm;
            %--------------------------------------------------------------
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
            % if isfield(obj.matrix,'br')
            %     if ~isempty(obj.matrix.br)
            %         hold on;
            %         f_quiver(obj.dom.parent_mesh.celem(:,obj.matrix.gindex), ...
            %                  obj.matrix.br(:,obj.matrix.gindex).','sfactor',0.2);
            %     end
            % end
        end
    end
end