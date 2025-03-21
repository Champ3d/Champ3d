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
