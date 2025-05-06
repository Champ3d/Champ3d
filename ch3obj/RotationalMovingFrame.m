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

classdef RotationalMovingFrame < MovingFrame
    
    properties
        rot_origin    % rot around o-->axis
        rot_axis      % rot around o-->axis
        rot_angle     % deg, counterclockwise convention
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'rot_origin','rot_axis','rot_angle'};
        end
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