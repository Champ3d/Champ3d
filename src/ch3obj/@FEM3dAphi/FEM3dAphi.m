%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAphi < EmModel
    
    % --- Contructor
    methods
        function obj = FEM3dAphi(args)
            arguments
                args.parent_mesh
                args.frequency
            end
            % ---
            obj@EmModel;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end