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

classdef BTorus < VolumeShape
    properties
        center = [0, 0, 0]
        rsection = 0
        rtorus = 1
        opening_angle = 360
        orientation = [0 0 1]
    end
    % --- Constructors
    methods
        function obj = BTorus(args)
            arguments
                args.center = [0, 0, 0]
                args.rtorus = 2
                args.rsection = 1
                args.opening_angle = 360
                args.orientation = [0 0 1]
            end
            % ---
            obj = obj@VolumeShape;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if (args.rsection <= 0) || (args.rtorus <= 0) || ...
               (args.rtorus < args.rsection) || (args.opening_angle == 0)
                error('Degenerated torus !');
            end
            % ---
            obj <= args;
            % ---
            BTorus.setup(obj);
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
            BTorus.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c   = obj.center.getvalue;
            rtorus  = obj.rtorus.getvalue;
            rsection  = obj.rsection.getvalue;
            opening_angle  = obj.opening_angle.getvalue;
            orientation = obj.orientation.getvalue;
            % ---
            geocode = GMSHWriter.btorus(c,rtorus,rsection,opening_angle,orientation);
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
