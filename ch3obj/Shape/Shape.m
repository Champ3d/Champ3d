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
        building_formular
        transform = {}
    end
    % --- Constructors
    methods
        function obj = Shape()
            obj = obj@Xhandle;
            obj.transform = {};
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
            obj.transform{end + 1} = struct('type','translate', ...
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
            obj.transform{end + 1} = struct('type','rotate', ...
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
            end
            % ---
            if length(args.scale) == 1
                args.scale = args.scale .* ones(size(args.origin));
            end
            % ---
            obj.transform{end + 1} = struct('type','dilate',...
                'origin',args.origin,'scale',args.scale);
            % ---
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        function set_parameter(obj)
            % --- XTODO
            % should put list in config file ?
            paramlist = {'r','center','bottom_cut_ratio','top_cut_ratio','opening_angle', ...
                         'len','orientation', ...
                         'rtorus','rsection', ...
                         'hei', ...
                         'ri','ro'};
            % ---
            for i = 1:length(paramlist)
                param = paramlist{i};
                if isprop(obj,param)
                    if isnumeric(obj.(param))
                        if ~isempty(obj.(param))
                            obj.(param) = Parameter('f',obj.(param));
                        end
                    elseif ~isa(obj.(param),'Parameter')
                        f_fprintf(1,'/!\\',0,'parameter must be numeric or Parameter !\n');
                        error('Parameter error');
                    end
                end
            end
        end
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
                            GMSHWriter.translate(t.distance,t.nb_copy)];
                    case 'rotate'
                        geocode = [geocode ...
                            GMSHWriter.rotate(t.origin,t.axis,t.angle,t.nb_copy)];
                    case 'dilate'
                        geocode = [geocode ...
                            GMSHWriter.dilate(t.origin,t.scale)];
                end
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods (Sealed)
        function objout = plus(obj,objx)
            % ---
            if isa(obj,'VolumeShape') && isa(objx,'VolumeShape')
                objout = VolumeShape;
            elseif isa(obj,'SurfaceShape') && isa(objx,'SurfaceShape')
                objout = SurfaceShape;
            elseif isa(obj,'CurveShape') && isa(objx,'CurveShape')
                objout = CurveShape;
            else
                % --- XTODO
                objout = [];
                return
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
            if isa(obj,'VolumeShape') && isa(objx,'VolumeShape')
                objout = VolumeShape;
            elseif isa(obj,'SurfaceShape') && isa(objx,'SurfaceShape')
                objout = SurfaceShape;
            elseif isa(obj,'CurveShape') && isa(objx,'CurveShape')
                objout = CurveShape;
            else
                objout = [];
                return
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
            if isa(obj,'VolumeShape') && isa(objx,'VolumeShape')
                objout = VolumeShape;
            elseif isa(obj,'SurfaceShape') && isa(objx,'SurfaceShape')
                objout = SurfaceShape;
            elseif isa(obj,'CurveShape') && isa(objx,'CurveShape')
                objout = CurveShape;
            else
                objout = [];
                return
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