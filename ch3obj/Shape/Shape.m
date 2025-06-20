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

classdef Shape < Xhandle
    properties
        geocode
        building_formular
        transform
    end
    % --- Constructors
    methods
        function obj = Shape()
            obj = obj@Xhandle;
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function translate(obj,args)
            arguments
                obj
                args.distance = [0 0 0]
                args.nb_copy = 0
            end
            % ---
            obj.transform = struct('type','translate', ...
                'distance',args.distance, ...
                'nb_copy',args.nb_copy);
            % ---
        end
        % -----------------------------------------------------------------
        function rotate(obj,args)
            arguments
                obj
                args.axis = [0 0 1]
                args.origin = [0 0 0]
                args.angle = 0
                args.nb_copy = 0
            end
            % ---
            obj.transform = struct('type','rotate', ...
                'axis',args.axis, ...
                'origin',args.origin,'angle',args.angle, ...
                'nb_copy',args.nb_copy);
            % ---
        end
        % -----------------------------------------------------------------
        function dilate(obj,args)
            arguments
                obj
                args.origin = [0 0 0]
                args.scale = [1 1 1]
                args.nb_copy = 0
            end
            % ---
            if length(args.scale) == 1
                args.scale = args.scale .* ones(size(args.origin));
            end
            % ---
            obj.transform = struct('type','dilate',...
                'origin',args.origin,'scale',args.scale, ...
                'nb_copy',args.nb_copy);
            % ---
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function objout = plus(obj,objx)
            % ---
            if isa(obj,'VolumeShape')
                objout = VolumeShape;
            end
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
            % ---
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '+';
        end
        function objout = minus(obj,objx)
            % ---
            if isa(obj,'VolumeShape')
                objout = VolumeShape;
            end
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
            % ---
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '-';
        end
        function objout = mpower(obj,objx)
            % ---
            if isa(obj,'VolumeShape')
                objout = VolumeShape;
            end
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
            % ---
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '^';
        end
    end
end