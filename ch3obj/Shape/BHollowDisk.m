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

classdef BHollowDisk < SurfaceShape
    properties
        center = [0, 0, 0]
        ri     = 1
        ro     = 2
    end
    % --- Constructors
    methods
        function obj = BHollowDisk(args)
            arguments
                args.center = [0, 0, 0]
                args.ri     = 1
                args.ro     = 2
            end
            % ---
            obj = obj@SurfaceShape;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if (args.ri < 0) || (args.ro <= 0)
                error('Degenerated hollow cylinder !');
            end
            % ---
            obj <= args;
            % ---
            BHollowDisk.setup(obj);
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
            BHollowDisk.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            c  = obj.center.getvalue;
            ri_ = obj.ri.getvalue;
            ro_ = obj.ro.getvalue;
            % ---
            geocode = GMSHWriter.bhollowdisk(c,ri_,ro_);
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
