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

classdef GCube < GShape3d
    properties

        center
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id'};
        end
    end
    % --- Constructors
    methods
        function obj = GCube(args)
            arguments
                args.id
            end
            % ---
            obj = obj@GShape3d;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Cube.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)

        end
    end
    methods (Access = public)
        function reset(obj)
            Cube.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        %------------------------------------------------------------------
    end

    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            % XTODO
        end
    end
end
