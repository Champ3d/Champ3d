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

classdef JsCoilAphi < Xhandle
    
    % --- computed
    properties (Access = private)
        build_done = 0
        assembly_done = 0
    end

    % --- Contructor
    methods
        function obj = JsCoilAphi()
            obj@Xhandle;
        end
    end

    % --- setup
    methods
        function setup(obj)
        end
    end

    % --- build
    methods
        function build(obj)
            if obj.build_done
                return
            end
            % --- current turn density vector field
            current_turn_density  = obj.matrix.unit_current_field .* obj.nb_turn ./ obj.cs_area;
            % ---
            js_array = obj.j_coil.getvalue('in_dom',obj.dom);
            js_array = js_array .* obj.matrix.unit_current_field;
            % ---
            gid_elem = obj.dom.gid_elem;
            wfjs = obj.parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',js_array);
            % ---
            obj.matrix.current_turn_density = current_turn_density;
            obj.matrix.wfjs = wfjs;
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
            wfjs = sparse(nb_face,1);
            %--------------------------------------------------------------
            gid_elem = obj.matrix.gid_elem;
            lmatrix = obj.matrix.wfjs;
            for i = 1:nbFa_inEl
                wfjs = wfjs + ...
                    sparse(id_face_in_elem(i,gid_elem),1,lmatrix(:,i),nb_face,1);
            end
            %--------------------------------------------------------------
            rotj   = obj.parent_model.parent_mesh.discrete.rot.' * wfjs;
            rotrot = obj.parent_model.parent_mesh.discrete.rot.' * ...
                     obj.parent_model.matrix.wfwf * ...
                     obj.parent_model.parent_mesh.discrete.rot;
            %--------------------------------------------------------------
            id_edge_t_unknown = obj.parent_model.matrix.id_edge_a;
            %--------------------------------------------------------------
            rotj = rotj(id_edge_t_unknown,1);
            rotrot = rotrot(id_edge_t_unknown,id_edge_t_unknown);
            %--------------------------------------------------------------
            t_jsfield = zeros(nb_edge,1);
            t_jsfield(id_edge_t_unknown) = f_solve_axb(rotrot,rotj);
            %--------------------------------------------------------------
            clear rotj rotrot wfjs
            %--------------------------------------------------------------
            obj.parent_model.dof.t_js = ...
                obj.parent_model.dof.t_js + t_jsfield;
            %--------------------------------------------------------------
            %obj.parent_model.dof.js = ...
            %    obj.parent_model.parent_mesh.discrete.rot * t_jsfield;
            %obj.parent_model.matrix.js = ...
            %    obj.parent_model.matrix.js + ...
            %    obj.parent_model.parent_mesh.field_wf('dof',obj.parent_model.dof.js);
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