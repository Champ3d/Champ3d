%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAphits < FEM3dAphi

    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','frequency'};
        end
    end
    % --- Constructor
    methods
        function obj = FEM3dAphits(args)
            arguments
                args.parent_mesh = []
                args.frequency = 0
            end
            % ---
            obj@FEM3dAphi;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup;
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    % --- Methods/public
    methods (Access = private)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end