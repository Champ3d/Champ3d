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

classdef FEMM2dBCmixed < FEMM2dBC
    properties
    end
    % --- Constructor
    methods
        function obj = FEMM2dBCmixed(args)
            arguments
                args.c0 = 0;
                args.c1 = 0;
            end
            % ---
            obj@FEMM2dBC;
            % ---
            obj <= args;
            % ---
            obj.bc_type = 'mixed';
            % ---
        end
    end
end