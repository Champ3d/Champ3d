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
                args.rot_origin = 0
                args.rot_axis   = 0
                args.rot_angle  = 0
            end
            % ---
            obj = obj@MovingFrame;
            % ---
            if isnumeric(args.rot_origin)
                args.rot_origin = Parameter('f',args.rot_origin);
            end
            % ---
            if isnumeric(args.rot_axis)
                args.rot_axis = Parameter('f',args.rot_axis);
            end
            % ---
            if isnumeric(args.rot_angle)
                args.rot_angle = Parameter('f',args.rot_angle);
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        function movnode = move(obj,fixnode)
            ori = obj.rot_origin.get;
            axi = obj.rot_axis.get;
            ang = obj.rot_angle.get;
            movnode = f_rotaroundaxis(fixnode, ...
                'rot_axis_origin',ori, ...
                'rot_axis',axi, ...
                'rot_angle',+ang);
        end
        function movnode = inverse_move(obj,fixnode)
            ori = obj.rot_origin.get;
            axi = obj.rot_axis.get;
            ang = obj.rot_angle.get;
            movnode = f_rotaroundaxis(fixnode, ...
                'rot_axis_origin',ori, ...
                'rot_axis',axi, ...
                'rot_angle',-ang);
        end
    end

end