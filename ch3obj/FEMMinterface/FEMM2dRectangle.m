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

classdef FEMM2dRectangle < FEMM2dDraw
    properties
        len_x
        len_y
        len_r
        len_theta
    end
    properties (Hidden)
        % ---
        sfactor = 1e2;
        cenxy_defined = 0;
        lenxy_defined = 0;
        % ---
        rsizevec
        tsizevec
        diagvec1
        diagvec2
    end
    % --- Constructor
    methods
        function obj = FEMM2dRectangle(args)
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
            d1 = obj.center - obj.diagvec1;
            d2 = obj.center - obj.diagvec2;
            d3 = obj.center + obj.diagvec1;
            d4 = obj.center + obj.diagvec2;
            % ---
            mi_drawline(d1(1),d1(2),d2(1),d2(2));
            mi_drawline(d2(1),d2(2),d3(1),d3(2));
            mi_drawline(d3(1),d3(2),d4(1),d4(2));
            mi_drawline(d4(1),d4(2),d1(1),d1(2));
            % ---
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
            obj.bound.bottom.type = 'segment';
            mi_selectsegment(obj.bottom(1),obj.bottom(2));
            mi_setgroup(obj.bound.bottom.id);
            % ---
            id_bound_ = [id_box '_top_bound'];
            obj.bound.top.id = f_str2code(id_bound_,'code_type','integer');
            obj.bound.top.type = 'segment';
            mi_selectsegment(obj.top(1),obj.top(2));
            mi_setgroup(obj.bound.top.id);
            % ---
            id_bound_ = [id_box '_left_bound'];
            obj.bound.left.id = f_str2code(id_bound_,'code_type','integer');
            obj.bound.left.type = 'segment';
            mi_selectsegment(obj.left(1),obj.left(2));
            mi_setgroup(obj.bound.left.id);
            % ---
            id_bound_ = [id_box '_right_bound'];
            obj.bound.right.id = f_str2code(id_bound_,'code_type','integer');
            obj.bound.right.type = 'segment';
            mi_selectsegment(obj.right(1),obj.right(2));
            mi_setgroup(obj.bound.right.id);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        function preprocessing(obj)
            % ---
            preprocessing@FEMM2dDraw(obj);
            % ---
            if ~isempty(obj.len_x)
                obj.len_r = [];
                obj.len_theta = [];
                obj.lenxy_defined = 1;
                obj.orientation = [0,1];
            elseif ~isempty(obj.len_r)
                obj.len_x = [];
                obj.len_y = [];
                obj.lenxy_defined = 0;
                obj.orientation = f_normalize(obj.center);
            else
                warning('len_... is not defined');
            end
            % ---
            if obj.lenxy_defined
                rsizevec_ = [obj.len_x/2, 0];
                tsizevec_ = [0, obj.len_y/2];
            else
                rsizevec_ = obj.len_r/2 .* [cosd(obj.cen_theta) sind(obj.cen_theta)];
                tsizevec_ = obj.len_theta/2 .* [cosd(obj.cen_theta+90) sind(obj.cen_theta+90)];
            end
            % ---
            diagvec1_ = +rsizevec_ + tsizevec_;
            diagvec2_ = -rsizevec_ + tsizevec_;
            % -------------------------------------------------------------
            bottomright = obj.center - diagvec2_*(1-1/obj.sfactor);
            topright    = obj.center + diagvec1_*(1-1/obj.sfactor);
            bottomleft  = obj.center - diagvec1_*(1-1/obj.sfactor);
            topleft     = obj.center + diagvec2_*(1-1/obj.sfactor);
            % -------------------------------------------------------------
            bottom = obj.center - tsizevec_*(1-1/obj.sfactor);
            top    = obj.center + tsizevec_*(1-1/obj.sfactor);
            left   = obj.center - rsizevec_*(1-1/obj.sfactor);
            right  = obj.center + rsizevec_*(1-1/obj.sfactor);
            % -------------------------------------------------------------
            % for choose (selectrectangle)
            out_bottomright = obj.center - diagvec2_*(1+1/obj.sfactor);
            out_topright    = obj.center + diagvec1_*(1+1/obj.sfactor);
            out_bottomleft  = obj.center - diagvec1_*(1+1/obj.sfactor);
            out_topleft     = obj.center + diagvec2_*(1+1/obj.sfactor);
            % -------------------------------------------------------------
            obj.rsizevec = rsizevec_;
            obj.tsizevec = tsizevec_;
            obj.diagvec1 = diagvec1_;
            obj.diagvec2 = diagvec2_;
            % -------------------------------------------------------------
            obj.bottomright = bottomright;
            obj.bottomleft  = bottomleft;
            obj.topright = topright;
            obj.topleft  = topleft;
            % -------------------------------------------------------------
            obj.bottom = bottom;
            obj.top    = top;
            obj.left   = left;
            obj.right  = right;
            % -------------------------------------------------------------
            obj.out_bottomright = out_bottomright;
            obj.out_topright  = out_topright;
            obj.out_bottomleft = out_bottomleft;
            obj.out_topleft  = out_topleft;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
        
    end
end