%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAphijw < FEM3dAphi
    % --- Constructor
    methods
        function obj = FEM3dAphijw(args)
            arguments
                args.id = 'no_id'
                % ---
                args.parent_mesh = []
                args.frequency = 0
            end
            % ---
            argu = f_to_namedarg(args);
            obj = obj@FEM3dAphi(argu{:});
            % ---
        end
    end
end