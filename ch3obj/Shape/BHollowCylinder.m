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

classdef BHollowCylinder < VolumeShape
    properties
        center = [0, 0, 0]
        ri     = 1
        ro     = 2
        hei    = 1
        orientation = [0 0 1]
        opening_angle = 360
    end
    % --- Constructors
    methods
        function obj = BHollowCylinder(args)
            arguments
                args.center = [0, 0, 0]
                args.ri     = 1
                args.ro     = 2
                args.hei    = 1
                args.orientation = [0 0 1]
                args.opening_angle = 360
            end
            % ---
            obj = obj@VolumeShape;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if (args.hei <= 0) || (args.ri < 0) || (args.ro <= 0)
                error('Degenerated hollow cylinder !');
            end
            % ---
            obj <= args;
            % ---
            BHollowCylinder.setup(obj);
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
            BHollowCylinder.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c  = obj.center.getvalue;
            ri = obj.ri.getvalue;
            ro = obj.ro.getvalue;
            hei = obj.hei.getvalue;
            opening_angle = obj.opening_angle.getvalue;
            orientation = obj.orientation.getvalue;
            % ---
            geocode = GMSHWriter.bhollowcylinder(c,ri,ro,hei,opening_angle,orientation);
            % ---
            geocode = obj.transformgeocode(geocode);
            % ---
        end
        %------------------------------------------------------------------
    end

    % --- Plot
    methods
        function plot(obj)
            % XTODO
        end
    end
end
