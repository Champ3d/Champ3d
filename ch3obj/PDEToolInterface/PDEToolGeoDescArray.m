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

classdef PDEToolGeoDescArray < Xhandle
    properties
        value
    end
    % --- Constructors
    methods
        function obj = PDEToolGeoDescArray(value)
            obj = obj@Xhandle;
            if nargin >= 1
                obj.value = value;
            end
        end
    end
    % --- transform
    methods
        function translate(obj,args)
            arguments
                obj
                args.distance = [0 0]
            end
            % ---
            obj.center = obj.center + args.distance;
            % ---
        end
    end
end