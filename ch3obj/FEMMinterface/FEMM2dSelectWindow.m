%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
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

classdef FEMM2dSelectWindow < Xhandle
    properties
        ref_point = [0,0] % must be in Oxy coordinates
        cen_x = 0
        cen_y = 0
        cen_r = 0
        cen_theta = 0
    end
    properties (Access = private)
        
    end

    % --- Constructor
    methods
        function obj = FEMM2dSelectWindow(args)
            arguments
                args
            end
            % ---
            if args.precision > 1e-8
                args.precision = 1e-8;
            end
            % ---
            obj@Xhandle;
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods/public
    methods (Access = public)
    end
end
