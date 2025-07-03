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

classdef BCoilShape < VolumeShape
    properties
        curve_shape
        cross_section
        rotation = 0
    end
    % --- Constructors
    methods
        function obj = BCoilShape(args)
            arguments
                args.curve_shape BCurve
                args.cross_section SurfaceShape
                args.rotation
            end
            % ---
            obj = obj@VolumeShape;
            % ---
            if ~isfield(args,'curve_shape') || ~isfield(args,'cross_section')
                error('#curve_shape and #cross_section must be given !');
            end
            % ---
            obj <= args;
            % ---
            BCoilShape.setup(obj);
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
            BCoilShape.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            geocode = [newline obj.curve_shape.geocode newline];
            geocode = [geocode obj.cross_section.geocode newline];
            % ---
            vcs  = [0 0 1];
            vcur = [obj.curve_shape.x(2) - obj.curve_shape.x(1), ...
                    obj.curve_shape.y(2) - obj.curve_shape.y(1), ...
                    obj.curve_shape.z(2) - obj.curve_shape.z(1)];
            % ---
            fit_axis = cross(vcs, vcur);
            fit_angle = acosd(dot(vcs,vcur) / (norm(vcs) * norm(vcur)));
            % ---
            if norm(fit_axis) < 1e-12
                fit_axis = [0 0 1];
                fit_angle = 0;
            end
            rotation_ = obj.rotation.getvalue;
            geocode = [geocode GMSHWriter.finish_coilshape(fit_axis,fit_angle,rotation_) newline];
        end
        %------------------------------------------------------------------
    end
end
