%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef PDEToolShape2d < Xhandle
    properties
        choosed_by
        bottom
        top
        left
        right
    end
    properties
        building_formular   % XTODO
    end
    % --- Constructors
    methods
        function obj = PDEToolShape2d()
            obj = obj@Xhandle;
        end
    end
    % --- geo desc array
    methods (Abstract)
        geodesc(obj) % must be in column format !
    end
    % --- transform
    methods
        function translate(obj,args)
            arguments
                obj
                args.distance = [0 0]
            end
            % ---
            obj.center = obj.center + args.distance;
            % ---
        end
        % ---
        function rotate(obj,args)
            arguments
                obj
                args.angle = 0
            end
            % ---
            obj.center = f_rotaroundaxis(obj.center.',...
                "axis_origin",[0 0],"rot_axis",[0 0 1],"rot_angle",args.angle);
            obj.center = obj.center.';
            obj.orientation = obj.orientation + args.angle;
            % ---
        end
    end
    % --- boolean -- XTODO
    methods (Sealed)
        function objout = plus(obj,objx)
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '+';
        end
        function objout = minus(obj,objx)
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '-';
        end
        function objout = mpower(obj,objx)
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '*';
        end 
    end
end