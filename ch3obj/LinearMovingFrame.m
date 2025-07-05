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

classdef LinearMovingFrame < MovingFrame
    
    properties
        lin_dir       % linear mov direction
        lin_step      % linear mov step
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'lin_dir','lin_step'};
        end
    end
    % --- Contructor
    methods
        function obj = LinearMovingFrame(args)
            arguments
                args.lin_dir  = 0
                args.lin_step = 0
            end
            % ---
            obj = obj@MovingFrame;
            % ---
            if isnumeric(args.lin_dir)
                args.lin_dir = Parameter('f',args.lin_dir);
            end
            % ---
            if isnumeric(args.lin_step)
                args.lin_step = Parameter('f',args.lin_step);
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
            if isempty(t)
                ldir = obj.lin_dir.getvalue;
                lstp = obj.lin_step.getvalue;
                moved = node + lstp .* ldir;
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
                    ldir = obj.lin_dir.getvalue;
                    lstp = obj.lin_step.getvalue;
                    moved = node + lstp .* ldir;
                else
                    % ---
                    ltime.it = back_it;
                    ldir01 = obj.lin_dir.getvalue;
                    lstp01 = obj.lin_step.getvalue;
                    move01 = node + lstp01 .* ldir01;
                    % ---
                    ltime.it = next_it;
                    ldir02 = obj.lin_dir.getvalue;
                    lstp02 = obj.lin_step.getvalue;
                    move02 = node + lstp02 .* ldir02;
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

        function moved = inverse_movenode(obj,node,t)
            arguments
                obj
                node
                t = []
            end
            % ---
            if isempty(t)
                ldir = obj.lin_dir.getvalue;
                lstp = obj.lin_step.getvalue;
                moved = node - lstp .* ldir;
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
                    ldir = obj.lin_dir.getvalue;
                    lstp = obj.lin_step.getvalue;
                    moved = node - lstp .* ldir;
                else
                    % ---
                    ltime.it = back_it;
                    ldir01 = obj.lin_dir.getvalue;
                    lstp01 = obj.lin_step.getvalue;
                    move01 = node - lstp01 .* ldir01;
                    % ---
                    ltime.it = next_it;
                    ldir02 = obj.lin_dir.getvalue;
                    lstp02 = obj.lin_step.getvalue;
                    move02 = node - lstp02 .* ldir02;
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

        function moved = movevector(obj,vector,t)
            arguments
                obj
                vector
                t = []
            end
            moved = vector;
        end

        function moved = inverse_movevector(obj,vector,t)
            arguments
                obj
                vector
                t = []
            end
            moved = vector;
        end
    end

end