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

classdef SCircle < PDEToolShape2d
    properties
        center = [0 0]
        r = 1
        dnum = 2
    end
    % --- Constructors
    methods
        function obj = SCircle(args)
            arguments
                args.id = []
                args.center = [0 0]
                args.r = 1
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
            a = linspace(0,360,obj.dnum);
            a(obj.dnum) = [];
            % ---
            x = obj.r .* cosd(a);
            y = obj.r .* sind(a);
            % ---
            x = x + obj.center(1);
            y = y + obj.center(2);
            % ---
            da = (a(2) - a(1))/2;
            dr = 1e-6;
            r_in = obj.r * cosd(da) - dr;
            obj.bottom = [0, -r_in] + obj.center;
            obj.top    = [0, +r_in] + obj.center;
            obj.left   = [-r_in, 0] + obj.center;
            obj.right  = [+r_in, 0] + obj.center;
            % ---
            nbp = length(x);
            gd = [2, nbp, x, y].';
        end
    end
end