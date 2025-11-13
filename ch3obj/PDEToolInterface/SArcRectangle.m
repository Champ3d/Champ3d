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

classdef SArcRectangle < PDEToolShape2d
    properties
        center = [0 0]
        ri = 0
        ro = 1
        openi = 0
        openo = 0
        orientation = 0 % deg, 0 = Ox, ccw
        dnum = 2
    end
    % --- Constructors
    methods
        function obj = SArcRectangle(args)
            arguments
                args.id = []
                args.center = [0 0]
                args.ri = 0
                args.ro = 1
                args.openi = 0
                args.openo = 0
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
            x1 = + obj.ri * cosd(obj.openi/2);
            x2 = + obj.ro * cosd(obj.openo/2);
            x3 = + obj.ro * cosd(obj.openo/2);
            x4 = + obj.ri * cosd(obj.openi/2);
            % ---
            y1 = - obj.ri * sind(obj.openi/2);
            y2 = - obj.ro * sind(obj.openo/2);
            y3 = + obj.ro * sind(obj.openo/2);
            y4 = + obj.ri * sind(obj.openi/2);
            % ---
            ai = linspace(+obj.openi/2, -obj.openi/2, obj.dnum);
            ao = linspace(-obj.openo/2, +obj.openo/2, obj.dnum);
            % ---
            x = [linspace(x1,x2,obj.dnum), obj.ro .* cosd(ao), ...
                 linspace(x3,x4,obj.dnum), obj.ri .* cosd(ai)];
            x(obj.dnum .* [1 2 3 4]) = [];
            y = [linspace(y1,y2,obj.dnum), obj.ro .* sind(ao), ...
                 linspace(y3,y4,obj.dnum), obj.ri .* sind(ai)];
            y(obj.dnum .* [1 2 3 4]) = [];
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
            % ---
            nbp = length(x);
            gd = [2, nbp, x, y].';
            % --- XTODO
            e = 1e-3;
            % ---
            da = (ai(2) - ai(1))/2;
            r_ = obj.ri * cosd(da) + e * obj.ri;
            p = [+r_, 0] + obj.center;
            bottom = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            da = (ao(2) - ao(1))/2;
            r_ = obj.ro * cosd(da) - e * obj.ro;
            p = [+r_, 0] + obj.center;
            top = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            rmean = (obj.ri + obj.ro)/2;
            hmin = min(obj.ri*sind(obj.openi/2), obj.ro*sind(obj.openo/2));
            p = [rmean, +hmin] + obj.center;
            left = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            p = [rmean, -hmin] + obj.center;
            right = f_rotaroundaxis(p.',"axis_origin",obj.center,"rot_axis",[0 0 1],"rot_angle",obj.orientation);
            % ---
            obj.top = top;
            obj.bottom = bottom;
            obj.left = left;
            obj.right = right;
        end
    end
end