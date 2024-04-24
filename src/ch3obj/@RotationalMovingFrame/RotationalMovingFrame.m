%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef RotationalMovingFrame < MovingFrame
    
    properties
        rot_origin    % rot around o-->axis
        rot_axis      % rot around o-->axis
        rot_angle     % deg, counterclockwise convention
    end

    % --- Contructor
    methods
        function obj = RotationalMovingFrame(args)
            arguments
                args.rot_origin = []
                args.rot_axis = []
                args.rot_angle = []
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        function node = move(obj,mesh)
        end
        function node = inverse_move(obj,mesh)
        end
    end

end