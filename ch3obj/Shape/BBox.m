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

classdef BBox < VolumeShape
    properties
        center = [0, 0, 0]
        len    = [1, 1, 1]
        orientation = [0 0 1]
    end
    % --- Constructors
    methods
        function obj = BBox(args)
            arguments
                args.center = [0, 0, 0]
                args.len    = [1, 1, 1]
                args.orientation = [0 0 1]
            end
            % ---
            obj = obj@VolumeShape;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if any(args.len == 0)
                error('Degenerated box ! one of len is zero.');
            end
            % ---
            obj <= args;
            % ---
            BBox.setup(obj);
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
            BBox.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c   = obj.center.getvalue;
            len = obj.len.getvalue;
            orientation = obj.orientation.getvalue;
            % ---
            geocode = GMSHWriter.bbox(c,len,orientation);
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
