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

classdef FEMM2dBCopen < FEMM2dBC
    properties
        n = 1
        ro
    end
    % --- Constructor
    methods
        function obj = FEMM2dBCopen(args)
            arguments
                args.ro = 0;
                args.n = 1;
            end
            % ---
            obj@FEMM2dBC;
            % ---
            obj <= args;
            % ---
            obj.c0 = obj.n/(4*pi*1e-7 * obj.ro);
            obj.c1 = 0;
            % ---
            obj.bc_type = 'open';
            % ---
        end
    end
end