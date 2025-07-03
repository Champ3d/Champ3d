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

classdef BCylinder < VolumeShape
    properties
        center = [0, 0, 0]
        r      = 1
        hei    = 1
        orientation = [0 0 1]
        opening_angle = 360
    end
    % --- Constructors
    methods
        function obj = BCylinder(args)
            arguments
                args.center = [0, 0, 0]
                args.r      = 1
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
            if (args.hei <= 0) || (args.r <= 0)
                error('Degenerated cylinder !');
            end
            % ---
            obj <= args;
            % ---
            BCylinder.setup(obj);
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
            BCylinder.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c = obj.center.getvalue;
            r_ = obj.r.getvalue;
            hei_ = obj.hei.getvalue;
            opening_angle_ = obj.opening_angle.getvalue;
            orientation_ = obj.orientation.getvalue;
            % ---
            geocode = GMSHWriter.bcylinder(c,r_,hei_,opening_angle_,orientation_);
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
