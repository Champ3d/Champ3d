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

classdef FEMM2dDraw < Xhandle
    properties
        % ---
        ref_point     % must be in Oxy coordinates
        % ---
        cen_x
        cen_y
        cen_r
        cen_theta
        % ---
        base_x
        base_y
        base_r
        base_theta
        % ---
        direction
        % ---
        bottom
        top
        left
        right
        % ---
        bottomright
        bottomleft
        topright
        topleft
        % ---
        center = [0,0]  % given in Oxy coordinates
        base
        orientation     % given in Oxy coordinates
        % ---
        parent_model
    end
    % --- Constructor
    methods
        function obj = FEMM2dDraw()
            obj@Xhandle
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        % --- depend on how center was defined
        function preprocessing(obj)
            if ~isempty(obj.cen_x)
                obj.cen_r = sqrt(obj.cen_x^2 + obj.cen_y^2);
                obj.cen_theta = atand(obj.cen_y/obj.cen_x);
                obj.cenxy_defined = 1;
            elseif ~isempty(obj.cen_r)
                obj.cen_x = obj.cen_r * cosd(obj.cen_theta);
                obj.cen_y = obj.cen_r * sind(obj.cen_theta);
                obj.cenxy_defined = 0;
            else
                warning('cen_... is not defined');
            end
            % ---
            obj.center(1) = obj.cen_x;
            obj.center(2) = obj.cen_y;
            obj.center    = obj.center + obj.ref_point;
            % ---
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
    end
end