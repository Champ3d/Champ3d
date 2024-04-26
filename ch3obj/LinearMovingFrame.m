%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LinearMovingFrame < MovingFrame
    
    properties
        lin_dir       % linear mov direction
        lin_step      % linear mov step
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