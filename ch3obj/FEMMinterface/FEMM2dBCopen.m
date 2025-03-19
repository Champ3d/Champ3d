%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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