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
        sfactor = 1e2;
        cenxy_defined = 0;
        lenxy_defined = 0;
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
            if obj.lenxy_defined
                rsizevec = [obj.len_x/2, 0];
                tsizevec = [0, obj.len_y/2];
            else
                rsizevec = obj.len_r/2 .* [cosd(obj.cen_theta) sind(obj.cen_theta)];
                tsizevec = obj.len_theta/2 .* [cosd(obj.cen_theta+90) sind(obj.cen_theta+90)];
            end
            % ---
            diagvec1 = +rsizevec + tsizevec;
            diagvec2 = -rsizevec + tsizevec;
            % ---
            d1 = obj.center - diagvec1;
            d2 = obj.center - diagvec2;
            d3 = obj.center + diagvec1;
            d4 = obj.center + diagvec2;
            % ---
            mi_drawline(d1(1),d1(2),d2(1),d2(2));
            mi_drawline(d2(1),d2(2),d3(1),d3(2));
            mi_drawline(d3(1),d3(2),d4(1),d4(2));
            mi_drawline(d4(1),d4(2),d1(1),d1(2));
            % -------------------------------------------------------------
            bottomright = obj.center - diagvec1*(1-1/obj.sfactor);
            topright    = obj.center - diagvec2*(1-1/obj.sfactor);
            bottomleft  = obj.center + diagvec1*(1-1/obj.sfactor);
            topleft     = obj.center + diagvec2*(1-1/obj.sfactor);
            % -------------------------------------------------------------
            obj.bottomright = bottomright;
            obj.bottomleft  = bottomleft;
            obj.topright = topright;
            obj.topleft  = topleft;
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
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
        
    end
end