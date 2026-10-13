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

classdef CurveShape < Shape
    % --- Constructors
    methods
        function obj = CurveShape()
            obj = obj@Shape;
        end
    end
    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        function set_parameter(obj)
            % --- for obj
            paramlist = {'rmin','cutfactor'};
            % ---
            for i = 1:length(paramlist)
                param = paramlist{i};
                if isprop(obj,param)
                    if isnumeric(obj.(param))
                        obj.(param) = Parameter('f',obj.(param));
                    elseif ~isa(obj.(param),'Parameter')
                        f_fprintf(1,'/!\\',0,'parameter must be numeric or Parameter !\n');
                        error('Parameter error');
                    end
                end
            end
            % --- for go
            paramlist = {'len','lenx','leny','lenz','angle','center','dnum'};
            % ---
            for i = 1:length(paramlist)
                param = paramlist{i};
                for j = 1:length(obj.go)
                    if isprop(obj.go{j},param)
                        if isnumeric(obj.go{j}.(param))
                            obj.go{j}.(param) = Parameter('f',obj.go{j}.(param));
                        elseif ~isa(obj.go{j}.(param),'Parameter')
                            f_fprintf(1,'/!\\',0,'parameter must be numeric or Parameter !\n');
                            error('Parameter error');
                        end
                    end
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function geocode = transformgeocode(obj,geocode)
            arguments
                obj
                geocode
            end
            % --- XTODO
            for i = 1:length(obj.transform)
                t = obj.transform{i};
                switch t.type
                    case 'translate'
                        geocode = [geocode ...
                            GMSHWriter.translate_curve(t.distance,t.nb_copy)];
                    case 'rotate'
                        geocode = [geocode ...
                            GMSHWriter.rotate_curve(t.origin,t.axis,t.angle,t.nb_copy)];
                    case 'dilate'
                        geocode = [geocode ...
                            GMSHWriter.dilate_curve(t.origin,t.scale)];
                end
            end
        end
        % -----------------------------------------------------------------
    end
end
