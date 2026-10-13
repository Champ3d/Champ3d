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

classdef FEM3dVjw < FEM3dV
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','frequency'};
        end
    end
    % --- Contructor
    methods
        function obj = FEM3dVjw(args)
            arguments
                args.parent_mesh = []
                args.frequency = 0
            end
            % ---
            argu = f_to_namedarg(args,'for','FEM3dV');
            obj = obj@FEM3dV(argu{:});
            % ---
            obj <= args;
            % ---
            obj.setup;
        end
    end
end