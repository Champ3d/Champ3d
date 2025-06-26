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

classdef BSphere < VolumeShape
    properties
        r = 1
        center = [0, 0, 0]
        bottom_cut_ratio = 0
        top_cut_ratio = 0
        opening_angle = 360
    end
    % --- Constructors
    methods
        function obj = BSphere(args)
            arguments
                args.r = 1
                args.center = [0, 0, 0]
                args.bottom_cut_ratio = 0
                args.top_cut_ratio = 0
                args.opening_angle = 360
            end
            % ---
            obj = obj@VolumeShape;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            if (args.bottom_cut_ratio == 1 && args.top_cut_ratio == 1)
                error('Degenerated sphere ! #bottom_cut_ratio = 1, #top_cut_ratio = 1');
            end
            % ---
            obj <= args;
            % ---
            BSphere.setup(obj);
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
            BSphere.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            r_    = obj.r.getvalue;
            c     = obj.center.getvalue;
            bcut  = obj.bottom_cut_ratio.getvalue;
            tcut  = obj.top_cut_ratio.getvalue;
            angle = obj.opening_angle.getvalue;
            % ---
            geocode = GMSHWriter.bsphere(r_,c,bcut,tcut,angle);
            % ---
            geocode = obj.transformgeocode(geocode);
            % ---
        end
        %------------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj)
            % XTODO
        end
    end
end
