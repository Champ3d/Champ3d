%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef JsCoilAphi < Xhandle
    
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
            % --- current turn density vector field
            current_turn_density  = obj.matrix.unit_current_field .* obj.nb_turn ./ obj.cs_area;
            % ---
            js_array = obj.j_coil.get_on(obj.dom);
            js_array = js_array .* obj.matrix.unit_current_field;
            % ---
            gid_elem = obj.dom.gid_elem;
            wfjs = obj.parent_mesh.cwfvf('id_elem',gid_elem,'vector_field',js_array);
            % ---
            obj.matrix.current_turn_density = current_turn_density;
            obj.matrix.wfjs = wfjs;
            % ---
        end
    end
end