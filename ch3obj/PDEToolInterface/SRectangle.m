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

classdef SRectangle < PDEToolShape2d
    properties
        center = [0 0]
        len = [1 1 1]   % [base1 height base2]
        orientation = 0 % deg, 0 = Ox, ccw
        dnum = 2
    end
    % --- Constructors
    methods
        function obj = SRectangle(args)
            arguments
                args.id = []
                args.center = [0 0]
                args.len = [1 1 1]
                args.orientation = 0
                args.dnum = 2
                args.choosed_by {mustBeMember(args.choosed_by,{'center','top','bottom','left','right'})} = 'center'
            end
            obj = obj@PDEToolShape2d;
            % ---
            if isempty(args.id)
                error("#id must be given !");
            end
            % ---
            if args.dnum <= 1
                args.dnum = 2;
            end
            % ---
            if length(args.len) < 3
                args.len = [args.len, args.len(1) .* ones(1, 3 - length(args.len))];
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % ---
    methods
        function gd = geodesc(obj)
            % ---
            x1 = - obj.len(2)/2;
            x2 = + obj.len(2)/2;
            x3 = + obj.len(2)/2;
            x4 = - obj.len(2)/2;
            % ---
            y1 = - obj.len(1)/2;
            y2 = - obj.len(3)/2;
            y3 = + obj.len(3)/2;
            y4 = + obj.len(1)/2;
            % ---
            x = [linspace(x1,x2,obj.dnum), linspace(x2,x3,obj.dnum), ...
                 linspace(x3,x4,obj.dnum), linspace(x4,x1,obj.dnum)];
            x(obj.dnum .* [1 2 3 4]) = [];
            y = [linspace(y1,y2,obj.dnum), linspace(y2,y3,obj.dnum), ...
                 linspace(y3,y4,obj.dnum), linspace(y4,y1,obj.dnum)];
            y(obj.dnum .* [1 2 3 4]) = [];
            % ---
            x = x + obj.center(1);
            y = y + obj.center(2);
            % ---
            if obj.orientation ~= 0
                p = [x; y];
                p = f_rotaroundaxis(p,"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
                x = p(1,:);
                y = p(2,:);
            end
            nbp = length(x);
            gd = [2, nbp, x, y].';
            % --- XTODO
            e = 1e-3;
            % ---
            p = [+(1-e) * obj.len(2)/2, 0] + obj.center;
            top = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            p = [-(1-e) * obj.len(2)/2, 0] + obj.center;
            bottom = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            basemin = min(obj.len([1 3]));
            p = [0, +(1-e) * basemin/2] + obj.center;
            left = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            p = [0, -(1-e) * basemin/2] + obj.center;
            right = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            obj.top = top;
            obj.bottom = bottom;
            obj.left = left;
            obj.right = right;
            % --- XTODO
            % da = (a(2) - a(1))/2;
            % dr = 1e-6;
            % r_in = obj.r * cosd(da) - dr;
            % obj.bottom = [0, -r_in] + obj.center;
            % obj.top    = [0, +r_in] + obj.center;
            % obj.left   = [-r_in, 0] + obj.center;
            % obj.right  = [+r_in, 0] + obj.center;
        end
    end
end