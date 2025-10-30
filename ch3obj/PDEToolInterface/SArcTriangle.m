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

classdef SArcTriangle < PDEToolShape2d
    properties
        center = [0 0]
        r = 0
        open = 0
        orientation = 0 % deg, 0 = Ox, ccw
        dnum = 2
    end
    % --- Constructors
    methods
        function obj = SArcTriangle(args)
            arguments
                args.id = []
                args.center = [0 0]
                args.r = 0
                args.open = 0
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
            obj <= args;
            % ---
        end
    end
    % ---
    methods
        function gd = geodesc(obj)
            x1 = 0;
            x2 = + obj.r * cosd(obj.open/2);
            x3 = + obj.r * cosd(obj.open/2);
            % ---
            y1 = 0;
            y2 = - obj.r * sind(obj.open/2);
            y3 = + obj.r * sind(obj.open/2);
            % ---
            a = linspace(-obj.open/2, +obj.open/2, obj.dnum);
            % ---
            x = [linspace(x1,x2,obj.dnum), obj.r .* cosd(a), ...
                 linspace(x3,x1,obj.dnum)];
            x(obj.dnum .* [1 2 3]) = [];
            y = [linspace(y1,y2,obj.dnum), obj.r .* sind(a), ...
                 linspace(y3,y1,obj.dnum)];
            y(obj.dnum .* [1 2 3]) = [];
            % ---
            x = x + obj.center(1);
            y = y + obj.center(2);
            % ---
            if obj.orientation ~= 0
                p = [x; y];
                p = f_rotaroundaxis(p,"axis_origin",[0 0],"rot_axis",[0 0 1],"rot_angle",obj.orientation);
                x = p(1,:);
                y = p(2,:);
            end
            nbp = length(x);
            gd = [2, nbp, x, y].';
            % --- XTODO
            da = (a(2) - a(1))/2;
            dr = 1e-6;
            r_in = obj.r * cosd(da) - dr;
            obj.bottom = [dr, 0]    + obj.center;
            obj.top    = [+r_in, 0] + obj.center;
            obj.left   = obj.center;
            obj.right  = obj.center;
        end
    end
end