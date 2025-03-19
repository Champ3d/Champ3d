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

classdef FEMM2dHalfDisk < FEMM2dDraw
    properties
        r
        base_len
        arclen
        max_angle_len
        base_to_arc_len
    end
    properties (Hidden)
        sfactor = 1e4;
        basexy_defined = 0;
        arclen_defined = 0;
    end
    % --- Constructor
    methods
        function obj = FEMM2dHalfDisk(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.base_x = []
                args.base_y = []
                args.base_r = []
                args.base_theta = []
                args.orientation = 0
                args.r = []
                args.base_len = []
                args.arclen = []
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
            % ---
            ang1 = obj.orientation + 90;
            ang2 = obj.orientation - 90;
            % ---
            diagvec1 = obj.base_len/2 .* [cosd(ang1) sind(ang1)];
            diagvec2 = obj.base_len/2 .* [cosd(ang2) sind(ang2)];
            % ---
            d1 = obj.base + diagvec1;
            d2 = obj.base + diagvec2;
            % ---
            mi_drawline(d1(1),d1(2),d2(1),d2(2));
            mi_drawarc(d2(1),d2(2),d1(1),d1(2),obj.arclen,obj.max_angle_len);
            % -------------------------------------------------------------
            orivec = obj.base_to_arc_len .* [cosd(obj.orientation) sind(obj.orientation)];
            % -------------------------------------------------------------
            bottom = obj.base + orivec/obj.sfactor;
            top    = obj.base + orivec*(1-1/obj.sfactor);
            left   = obj.base + orivec/obj.sfactor + diagvec1*(1-1/obj.sfactor);
            right  = obj.base + orivec/obj.sfactor + diagvec2*(1-1/obj.sfactor);
            % -------------------------------------------------------------
            obj.bottom = bottom;
            obj.top    = top;
            obj.left   = left;
            obj.right  = right;
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
            % ---
            if ~isempty(obj.base_x)
                obj.base_r = sqrt(obj.base_x^2 + obj.base_y^2);
                if obj.base_x == 0
                    if obj.base_y == 0
                        obj.base_theta = 0;
                    else
                        obj.base_theta = sign(obj.base_x) * 90;
                    end
                else
                    obj.base_theta = atand(obj.base_y/obj.base_x);
                end
                obj.basexy_defined = 1;
            elseif ~isempty(obj.base_r)
                obj.base_x = obj.base_r * cosd(obj.base_theta);
                obj.base_y = obj.base_r * sind(obj.base_theta);
                obj.basexy_defined = 0;
            else
                warning('base_... is not defined');
            end
            % ---
            obj.base = [obj.base_x, obj.base_y] + obj.ref_point;
            % ---
            if ~isempty(obj.arclen)
                obj.base_len = 2 * sind(obj.arclen/2) * obj.r;
            elseif ~isempty(obj.base_len)
                obj.arclen = 2 * asind((obj.base_len/2) / obj.r);
            else
                warning('arclen or len must be defined');
            end
            % ---
            % ---
            alpha_ = obj.arclen/4;
            obj.base_to_arc_len = obj.base_len/2 * tand(alpha_);
            % ---
            obj.center(1) = obj.base(1) + cosd(obj.orientation) * obj.base_to_arc_len/2;
            obj.center(2) = obj.base(2) + sind(obj.orientation) * obj.base_to_arc_len/2;
            % ---
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
        
    end
end