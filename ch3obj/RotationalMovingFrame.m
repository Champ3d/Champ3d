%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

classdef RotationalMovingFrame < MovingFrame
    
    properties
        axis_origin   % rot around o-->axis
        rot_axis      % rot around o-->axis
        rot_angle     % deg, counterclockwise convention
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'rot_origin','rot_axis','rot_angle'};
        end
    end
    % --- Contructor
    methods
        function obj = RotationalMovingFrame(args)
            arguments
                args.axis_origin = 0
                args.rot_axis   = 0
                args.rot_angle  = 0
            end
            % ---
            obj = obj@MovingFrame;
            % ---
            if isnumeric(args.axis_origin)
                args.axis_origin = Parameter('f',args.axis_origin);
            end
            % ---
            if isnumeric(args.rot_axis)
                args.rot_axis = Parameter('f',args.rot_axis);
            end
            % ---
            if isnumeric(args.rot_angle)
                args.rot_angle = Parameter('f',args.rot_angle);
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        function moved = movenode(obj,node,t)
            arguments
                obj
                node
                t = []
            end
            % ---
            moved = obj.move(node,'direct','node',t);
        end
        function moved = inverse_movenode(obj,node,t)
            arguments
                obj
                node
                t = []
            end
            % ---
            moved = obj.move(node,'inverse','node',t);
        end
        function moved = movevector(obj,vector,t)
            arguments
                obj
                vector
                t = []
            end
            % ---
            moved = obj.move(vector,'direct','vector',t);
        end
        function moved = inverse_movevector(obj,vector,t)
            arguments
                obj
                vector
                t = []
            end
            % ---
            moved = obj.move(vector,'inverse','vector',t);
        end
    end

    % --- 
    methods (Access = private)
        function moved = move(obj,value,sens,type,t)
            arguments
                obj
                value
                sens {mustBeMember(sens,{'direct','inverse'})}
                type {mustBeMember(type,{'node','vector'})}
                t
            end
            % ---
            if isempty(t)
                ori = obj.axis_origin.getvalue;
                axi = obj.rot_axis.getvalue;
                ang = obj.rot_angle.getvalue;
                % ---
                switch type
                    case 'vector'
                        ori = [0 0 0].';
                end
                % ---
                switch sens
                    case 'inverse'
                        ang = -ang;
                end
                % ---
                moved = f_rotaroundaxis(value, ...
                    'axis_origin',ori, ...
                    'rot_axis',axi, ...
                    'rot_angle',ang);
            else
                % ---
                ltime = obj.parent_model.ltime;
                it0 = ltime.it;
                % ---
                next_it = ltime.next_it(t);
                back_it = ltime.back_it(t);
                % ---
                if next_it == back_it
                    ltime.it = back_it;
                    % ---
                    ori = obj.axis_origin.getvalue;
                    axi = obj.rot_axis.getvalue;
                    ang = obj.rot_angle.getvalue;
                    % ---
                    switch type
                        case 'vector'
                            ori = [0 0 0].';
                    end
                    % ---
                    switch sens
                        case 'inverse'
                            ang = -ang;
                    end
                    % ---
                    moved = f_rotaroundaxis(value, ...
                        'axis_origin',ori, ...
                        'rot_axis',axi, ...
                        'rot_angle',ang);
                else
                    % ---
                    ltime.it = back_it;
                    % ---
                    ori = obj.axis_origin.getvalue;
                    axi = obj.rot_axis.getvalue;
                    ang = obj.rot_angle.getvalue;
                    % ---
                    switch type
                        case 'vector'
                            ori = [0 0 0].';
                    end
                    % ---
                    switch sens
                        case 'inverse'
                            ang = -ang;
                    end
                    % ---
                    move01 = f_rotaroundaxis(value, ...
                        'axis_origin',ori, ...
                        'rot_axis',axi, ...
                        'rot_angle',ang);
                    % ---
                    ltime.it = next_it;
                    % ---
                    ori = obj.axis_origin.getvalue;
                    axi = obj.rot_axis.getvalue;
                    ang = obj.rot_angle.getvalue;
                    % ---
                    switch type
                        case 'vector'
                            ori = [0 0 0].';
                    end
                    % ---
                    switch sens
                        case 'inverse'
                            ang = -ang;
                    end
                    % ---
                    move02 = f_rotaroundaxis(value, ...
                        'axis_origin',ori, ...
                        'rot_axis',axi, ...
                        'rot_angle',ang);
                    % ---
                    delta_t = ltime.t_array(next_it) - ltime.t_array(back_it);
                    % ---
                    dt = t - ltime.t_array(back_it);
                    % ---
                    moved = move01 + (move02 - move01)./delta_t * dt;
                end
                % ---
                ltime.it = it0;
                % ---
            end
            % ---
        end
    end
end