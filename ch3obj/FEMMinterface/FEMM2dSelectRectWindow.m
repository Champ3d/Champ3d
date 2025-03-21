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
