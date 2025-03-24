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

classdef FEMM2dCircMovingFrame < FEMM2dMovingFrame
    properties
        r
    end
    properties (Access = private)
        
    end

    % --- Constructor
    methods
        function obj = FEMM2dCircMovingFrame(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = 0
                args.cen_y = 0
                args.cen_r = 0
                args.cen_theta = 0
                args.r = 0
            end
            % ---
            obj@FEMM2dMovingFrame;
            % ---
            obj <= args;
            % ---
            argu = f_to_namedarg(args);
            choosewindow = FEMM2dCircle(argu{:});
            % ---
            obj.center = choosewindow.center;
            obj.r = choosewindow.r;
            % ---
            clear choosewindow;
        end
    end

    % --- Methods/public
    methods (Access = public)
        function select(obj)
            % ---
            mi_clearselected;
            % ---
            mi_seteditmode('group');
            mi_selectcircle(obj.center(1),obj.center(2),obj.r);
        end
    end
end
