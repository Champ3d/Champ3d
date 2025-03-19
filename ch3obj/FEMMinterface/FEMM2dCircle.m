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

classdef FEMM2dCircle < FEMM2dDraw
    properties
        r
        max_angle_len
    end
    properties (Hidden)
        sfactor = 1e2;
        cenxy_defined = 0;
    end
    % --- Constructor
    methods
        function obj = FEMM2dCircle(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = []
                args.cen_y = []
                args.cen_r = []
                args.cen_theta = []
                args.r = []
                args.max_angle_len = 10
            end
            % ---
            obj@FEMM2dDraw;
            % ---
            obj <= args;
            % ---
            obj.preprocessing;
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        function choose(obj)
            % choose the dom
        end
        % -----------------------------------------------------------------
        function get(obj)
            % get integral quantities
        end
        % -----------------------------------------------------------------
        function setup(obj)
            % -------------------------------------------------------------
            x1 = obj.r * cosd(0)   + obj.center(1);
            x2 = obj.r * cosd(180) + obj.center(1);
            y1 = obj.r * sind(0)   + obj.center(2);
            y2 = obj.r * sind(180) + obj.center(2);
            mi_drawarc(x1,y1,x2,y2,180,obj.max_angle_len);
            mi_drawarc(x2,y2,x1,y1,180,obj.max_angle_len);
            % -------------------------------------------------------------
            obj.sfactor = 1/(1-cosd(obj.max_angle_len/2)) - 1; % -1 for security
            eps_r = obj.r * (1 - 1/obj.sfactor);
            obj.bottom(1) = eps_r * cosd(-90) + obj.center(1);
            obj.bottom(2) = eps_r * sind(-90) + obj.center(2);
            obj.top(1)    = eps_r * cosd(+90) + obj.center(1);
            obj.top(2)    = eps_r * sind(+90) + obj.center(2);
            obj.left(1)   = eps_r * cosd(180) + obj.center(1);
            obj.left(2)   = eps_r * sind(180) + obj.center(2);
            obj.right(1)  = eps_r * cosd(0)   + obj.center(1);
            obj.right(2)  = eps_r * sind(0)   + obj.center(2);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        function preprocessing(obj)
            preprocessing@FEMM2dDraw(obj);
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
    end
end