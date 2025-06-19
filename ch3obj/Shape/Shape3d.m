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

classdef Shape3d < Xhandle
    properties
        gmshgeocode
        building_formular
        % ---
        transform
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id'};
        end
    end
    % --- Constructors
    methods
        function obj = Shape3d()
            obj = obj@Xhandle;
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)

        end
    end
    methods (Access = public)
        function reset(obj)
            Shape3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Transformations
    methods
        % -----------------------------------------------------------------
        function build(obj)

        end
        % -----------------------------------------------------------------
        function translate(obj,args)
            arguments
                obj
                args.distance = [0 0 0]
            end
            % ---
            obj.transform = struct('type','translate','distance',args.distance);
            % ---
        end
        % -----------------------------------------------------------------
        function rotate(obj,args)
            arguments
                obj
                args.axis = [0 0 1];
                args.origin = [0 0 0];
                args.angle = 0;
            end
            % ---
            obj.transform = struct('type','rotate',...
                'axis',args.axis, ...
                'origin',args.origin,'angle',args.angle);
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
            obj.transform = struct('type','dilate',...
                'origin',args.origin,'scale',args.scale);
            % ---
        end
        % -----------------------------------------------------------------
        function duplicate(obj,args)
            arguments
                obj
                args
            end
            % ---
            obj.transform = struct('type','duplicate');
            % ---
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        function build_from_formular(obj)
            switch obj.building_formular.operation
                case '+'
                    
                case '-'
                    
                case '^'
                    
            end
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            % XTODO
        end
    end

    % --- Methods
    methods
        function objout = plus(obj,objx)
            objout = Shape3d;
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
            % ---
            objout.building_formular.arg1 = obj;
            objout.building_formular.arg2 = objx;
            objout.building_formular.operation = '+';
        end
        function objout = minus(obj,objx)
            objout = Shape3d;
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
        end
        function objout = mpower(obj,objx)
            objout = Shape3d;
            % ---
            obj.is_defining_obj_of(objout);
            objx.is_defining_obj_of(objout);
        end
    end
end
