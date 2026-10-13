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

classdef JsCoil < Xhandle
    % --- Contructor
    methods
        function obj = JsCoil()
            obj@Xhandle;
        end
    end
    % --- Utility Methods
    methods
        function [t_js,wfjs] = get_t_js(obj)
            % ---
            js_array = obj.matrix.js_array .* obj.matrix.unit_current_field;
            gindex = obj.matrix.gindex;
            %--------------------------------------------------------------
            % local wfjs matrix
            lmatrix = obj.parent_model.parent_mesh.cwfvf('id_elem',gindex,'vector_field',js_array);
            %--------------------------------------------------------------
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            nb_face = obj.parent_model.parent_mesh.nb_face;
            id_face_in_elem = obj.parent_model.parent_mesh.meshds.id_face_in_elem;
            nbFa_inEl = obj.parent_model.parent_mesh.refelem.nbFa_inEl;
            %--------------------------------------------------------------
            wfjs = sparse(nb_face,1);
            %--------------------------------------------------------------
            for i = 1:nbFa_inEl
                wfjs = wfjs + ...
                    sparse(id_face_in_elem(i,gindex),1,lmatrix(:,i),nb_face,1);
            end
            %--------------------------------------------------------------
            rotj   = obj.parent_model.parent_mesh.discrete.rot.' * wfjs;
            rotrot = obj.parent_model.parent_mesh.discrete.rot.' * ...
                     obj.parent_model.matrix.wfwf * ...
                     obj.parent_model.parent_mesh.discrete.rot;
            %--------------------------------------------------------------
            % id_edge_t_unknown = obj.parent_model.matrix.id_edge_a;
            % rotj = rotj(id_edge_t_unknown,1);
            % rotrot = rotrot(id_edge_t_unknown,id_edge_t_unknown);
            % t_js = zeros(nb_edge,1);
            %--------------------------------------------------------------
            % --- qmr + jacobi
            M = sqrt(diag(diag(rotrot)));
            [t_js,flag,relres,niter,resvec] = qmr(rotrot, rotj, 1e-6, 5e3, M.', M);
            %--------------------------------------------------------------
        end
    end
end