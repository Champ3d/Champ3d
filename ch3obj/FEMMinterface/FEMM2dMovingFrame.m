%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
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
        center
        id_group
        % ---
        parent_model
        % ---
        id_dom
        last_move
    end
    % ---
    properties (Access = private)
        
    end

    % --- Constructor
    methods
        function obj = FEMM2dMovingFrame()
            % ---
            obj@Xhandle;
            % ---
            obj.last_move{1} = [];
            % ---
        end
    end

    % --- Methods/public
    methods (Access = public)
        function rotate(obj,args)
            arguments
                obj
                args.xbase = 0;     % rot around base point
                args.ybase = 0;     % rot around base point
                args.angle = 0;     % deg, counterclockwise convention
                args.addtohistory = 1; % add to move history ?
            end
            % --- make sure that all dom are setted up
            obj.parent_model.setup;
            % ---
            obj.select;
            % ---
            mi_moverotate(args.xbase,args.ybase,args.angle);
            % ---
            nb_dom  = length(obj.id_dom);
            for i = 1:nb_dom
                % ---
                vdom = obj.parent_model.dom.(obj.id_dom{i});
                % ---
                choosept = [vdom.choosing_point.x;vdom.choosing_point.y];
                choosept = f_rotaroundaxis(choosept,...
                        'rot_axis_origin',[args.xbase,args.ybase],...
                        'rot_axis',[0 0 1],...
                        'rot_angle',args.angle);
                % ---
                vdom.choosing_point.x = choosept(1);
                vdom.choosing_point.y = choosept(2);
            end
            % ---
            if args.addtohistory
                lmove.move_type = 'rotate';
                lmove.move_args = args;
                obj.last_move{end+1} = lmove;
            end
        end
        % -----------------------------------------------------------------
        function translate(obj,args)
            arguments
                obj
                args.dx = 0;   % x-distance
                args.dy = 0;   % y-distance
                args.addtohistory = 1; % add to move history ?
            end
            % --- make sure that all dom are setted up
            obj.parent_model.setup;
            % ---
            obj.select;
            % ---
            mi_movetranslate(args.dx,args.dy);
            % ---
            nb_dom  = length(obj.id_dom);
            for i = 1:nb_dom
                % ---
                vdom = obj.parent_model.dom.(obj.id_dom{i});
                % ---
                vdom.choosing_point.x = vdom.choosing_point.x + args.dx;
                vdom.choosing_point.y = vdom.choosing_point.y + args.dy;
            end
            % ---
            if args.addtohistory
                lmove.move_type = 'translate';
                lmove.move_args = args;
                obj.last_move{end+1} = lmove;
            end
        end
        % -----------------------------------------------------------------
        function reset_last_move(obj)
            if length(obj.last_move) > 1  % 1 is empty
                if f_strcmpi(obj.last_move{end}.move_type,'rotate')
                    obj.rotate('xbase',obj.last_move{end}.move_args.xbase,...
                               'ybase',obj.last_move{end}.move_args.ybase,...
                               'angle', - obj.last_move{end}.move_args.angle,...
                               'addtohistory', 0);
                    % ---
                    obj.last_move(end) = [];
                    % ---
                elseif f_strcmpi(obj.last_move{end}.move_type,'translate')
                    obj.translate('dx', - obj.last_move{end}.move_args.dx,...
                                  'dy', - obj.last_move{end}.move_args.dy,...
                                  'addtohistory', 0);
                    % ---
                    obj.last_move(end) = [];
                    % ---
                end
            end
        end
        % -----------------------------------------------------------------
        function reset_all_move(obj)
            nb_move = length(obj.last_move) - 1; % 1 is empty
            if nb_move > 0  
                for i = 1:nb_move
                    obj.reset_last_move;
                end
            end
        end
        % -----------------------------------------------------------------
        function select(obj)
            obj.setup;
            mi_clearselected;
            mi_selectgroup(obj.id_group);
        end
        % -----------------------------------------------------------------
    end
    % ---------------------------------------------------------------------
    methods (Static)
        function imove = movecount()
            % ---
            persistent n
            if isempty(n)
                n = 0;
            end
            n = n + 1;
            % ---
            imove = n;
        end
    end
end
