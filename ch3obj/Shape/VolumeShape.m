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

classdef VolumeShape < Shape
    % --- Constructors
    methods
        function obj = VolumeShape()
            obj = obj@Shape;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            if ~isempty(obj.building_formular)
                geocode = obj.build_from_formular;
            end
        end
        %------------------------------------------------------------------
    end

    % --- Methods
    methods (Access = private)
        % -----------------------------------------------------------------
        function geocode = build_from_formular(obj)
            gcode1 = obj.building_formular.arg1.geocode;
            gcode2 = obj.building_formular.arg2.geocode;
            switch obj.building_formular.operation
                case '+'
                    geocode = [gcode1 newline gcode2];
                    opecode = GMSHWriter.union_volume;
                    geocode = [geocode newline opecode newline];
                case '-'
                    geocode = [gcode1 newline gcode2];
                    opecode = GMSHWriter.difference_volume;
                    geocode = [geocode newline opecode newline];
                case '^'
                    geocode = [gcode1 newline gcode2];
                    opecode = GMSHWriter.intersection_volume;
                    geocode = [geocode newline opecode newline];
            end
        end
        % -----------------------------------------------------------------
    end
    
    methods (Access = protected)
        % -----------------------------------------------------------------
        function geocode = transformgeocode(obj,geocode)
            arguments
                obj
                geocode
            end
            % ---
            for i = 1:length(obj.transform)
                t = obj.transform{i};
                switch t.type
                    case 'translate'
                        geocode = [geocode ...
                            GMSHWriter.translate_volume(t.distance,t.nb_copy)];
                    case 'rotate'
                        geocode = [geocode ...
                            GMSHWriter.rotate_volume(t.origin,t.axis,t.angle,t.nb_copy)];
                    case 'dilate'
                        geocode = [geocode ...
                            GMSHWriter.dilate_volume(t.origin,t.scale)];
                end
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            % XTODO
        end
    end
end
