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

classdef FEMM2dArcRectangle < FEMM2dDraw
    properties
    end
    % --- Constructor
    methods
        function obj = FEMM2dArcRectangle(args)
            arguments
                args.ref_point
                args.center
                args.r_in
                args.r_ex
                args.arc_len
            end
            % ---
            obj@FEMM2dDraw;
        end
    end
    % --- Methods/public
    methods (Access = public)
        function choose(obj)
            % choose the dom
        end
        function get(obj)
            % get integral quantities
        end
        function setup(obj)
            % get integral quantities
        end
    end
    % --- Methods/protected
    methods (Access = protected)
    end
    % --- Methods/private
    methods (Access = private)
    end
end