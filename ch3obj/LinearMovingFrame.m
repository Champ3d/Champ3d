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
        function movnode = move(obj,fixnode)
            ldir = obj.lin_dir.get;
            lstp = obj.lin_step.get;
            movnode = fixnode + lstp .* ldir;
        end
        function movnode = inverse_move(obj,fixnode)
            ldir = obj.lin_dir.get;
            lstp = obj.lin_step.get;
            movnode = fixnode - lstp .* ldir;
        end
    end

end