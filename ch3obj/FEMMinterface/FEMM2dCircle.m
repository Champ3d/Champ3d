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
                args.cen_x = 0
                args.cen_y = 0
                args.cen_r = 0
                args.cen_theta = 0
                args.r = 0
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
        function setbound(obj,id_box)
            arguments
                obj
                id_box
            end
            % ---
            id_bound_ = [id_box '_bottom_bound'];
            obj.bound.bottom.id = f_str2code(id_bound_,'code_type','integer');
            obj.bound.left.id = obj.bound.bottom.id; % same as bottom
            obj.bound.bottom.type = 'segment';
            obj.bound.left.type = 'segment';
            mi_selectsegment(obj.bottom(1),obj.bottom(2));
            mi_setgroup(obj.bound.bottom.id);
            
            % ---
            id_bound_ = [id_box '_top_bound'];
            obj.bound.top.id = f_str2code(id_bound_,'code_type','integer');
            obj.bound.right.id = obj.bound.top.id; % same as top
            obj.bound.top.type = 'arc_segment';
            obj.bound.right.type = 'arc_segment';
            mi_selectarcsegment(obj.top(1),obj.top(2));
            mi_setgroup(obj.bound.top.id);
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