%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
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
            argu = f_to_namedarg(args);
            obj = obj@FEM3dV(argu{:});
            % ---
            obj <= args;
            % ---
            obj.setup;
        end
    end
end