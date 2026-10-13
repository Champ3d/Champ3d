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
            % ---
            ANcell =+ (obj.parent_model.field{it}.A.elem({{gindex}}) * obj.uJfield(gindex));
            % ANcell =+ (obj.parent_model.field{it}.A.elem({{gindex}}) * obj.matrix.unit_current_field(gindex,:));
            % ---
            nbG   = length(ANcell);
            detJ  = zeros(nbG,length(gindex));
            ANmat = zeros(nbG,length(gindex));
            for i = 1:nbG
                ANmat(i,:) = ANcell{i}; 
                detJ(i,:)  = obj.parent_model.parent_mesh.intkit.detJ{i}(gindex);
            end
            % ---
            refelem = obj.parent_model.parent_mesh.refelem;
            wei = refelem.Weigh.';
            obj.Flux(it) = sum(sum(wei.*detJ.*ANmat)) .* obj.nb_turn ./ obj.cs_area;
            % ---
        end
    end
end