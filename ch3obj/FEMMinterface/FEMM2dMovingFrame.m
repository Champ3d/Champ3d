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

classdef FEMM2dMovingFrame < Xhandle
    properties
        id_moveframe
        % ---
        ref_point = [0,0] % must be in Oxy coordinates
        cen_x = 0
        cen_y = 0
        cen_r = 0
        cen_theta = 0
        % ---
        id_group
        % ---
        parent_model
        % ---
        id_dom
    end
    properties (Access = private)
        
    end

    % --- Constructor
    methods
        function obj = FEMM2dMovingFrame()
            % ---
            obj@Xhandle;
            % ---
        end
    end

    % --- Methods/public
    methods (Access = public)
        function rotate(obj,args)
            arguments
                obj
                args.xbase = 0;   % rot around base point
                args.ybase = 0;   % rot around base point
                args.angle = 0;   % deg, counterclockwise convention
            end
            % --- make sure that all dom are setted up
            obj.parent_model.setup;
            % ---
            obj.select;
            % ---
            mi_moverotate(args.xbase,args.ybase,args.angle);
            % ---
%             obj.last_move.move_type = 'rotate';
%             % ---
%             obj.last_move.move_args = args;
        end
        % -----------------------------------------------------------------
        function translate(obj)
            
        end
        % -----------------------------------------------------------------
        function reset(obj)

        end
        % -----------------------------------------------------------------
    end
end
