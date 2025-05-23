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

classdef StrandedCoil < Coil
    properties
        dofuJ
        uJfield
    end
    % --- Contructor
    methods
        function obj = StrandedCoil()
            obj@Coil;
        end
    end
    % --- Utility Methods
    methods
    % -----------------------------------------------------------------
        function getFlux(obj)
            it = obj.parent_model.ltime.it;
            gindex = obj.matrix.gindex;
            A = obj.parent_model.field{it}.A.elem.gvalue(gindex);
            N = obj.uJfield.gvalue(gindex);
            % ---
            AN = zeros(8,length(gindex));
            detJ = zeros(8,length(gindex));
            for i = 1:length(A)
                AN(i,:) = dot(A{i},N{i});
                detJ(i,:) = obj.parent_model.parent_mesh.intkit.detJ{i}(gindex);
            end
            % ---
            refelem = obj.parent_model.parent_mesh.refelem;
            wei = refelem.Weigh.';
            obj.Flux(it) = sum(sum(wei.*detJ.*AN)) .* obj.nb_turn ./ obj.cs_area;
            % ---
        end
    end
end