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

classdef BRectangle < SurfaceShape
    properties
        center = [0 0 0]
        len = [1 1]
        orientation = [1 0 0]
        r_corner = 0
        rmin
    end
    % --- Constructors
    methods
        function obj = BRectangle(args)
            arguments
                args.center = [0 0 0]
                args.len = [1 1]
                args.orientation = [1 0]
                args.r_corner = 0
            end
            % ---
            obj = obj@SurfaceShape;
            % ---
            obj <= args;
            % ---
            BRectangle.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            obj.set_parameter;
        end
    end
    methods (Access = public)
        function reset(obj)
            BRectangle.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c    = obj.center.getvalue;
            len_ = obj.len.getvalue;
            orientation_ = obj.orientation.getvalue;
            r_corner_ = obj.r_corner.getvalue;
            % ---
            geocode = GMSHWriter.brectangle(c,len_,orientation_,r_corner_);
            % ---
            geocode = obj.transformgeocode(geocode);
            % ---
        end
        %------------------------------------------------------------------
    end
end