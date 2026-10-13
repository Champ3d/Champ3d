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

classdef FEMM2dSelectRectWindow < FEMM2dSelectWindow
    properties
        len_x = 0
        len_y = 0
        len_r = 0
        len_theta = 0
    end
    properties (Access = private)
        
    end

    % --- Constructor
    methods
        function obj = FEMM2dSelectRectWindow(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = []
                args.cen_y = []
                args.cen_r = []
                args.cen_theta = []
                args.len_x = []
                args.len_y = []
                args.len_r = []
                args.len_theta = []
            end
            % ---
            obj@FEMM2dSelectWindow;
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods/public
    methods (Access = public)
    end
end
