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

classdef SolidCoilAphi < Econductor

    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end

    % --- Contructor
    methods
        function obj = SolidCoilAphi()
            obj@Econductor;
            % ---
            SolidCoilAphi.setup(obj);
            % ---
            % must reset build+assembly
            obj.build_done = 0;
            obj.assembly_done = 0;
        end
    end
    
    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@Econductor(obj);
            % ---
            obj.setup_done = 1;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % ---
            % must reset setup+build+assembly
            obj.setup_done = 0;
            obj.build_done = 0;
            obj.assembly_done = 0;
            % ---
            % must call super reset
            % ,,, with obj as argument
            reset@Econductor(obj);
        end
    end
    methods
        function build(obj)
            % ---
            SolidCoilAphi.setup(obj);
            % ---
            build@Econductor(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@Econductor(obj);
            % ---
            if obj.assembly_done
                return
            end
            % ---
            obj.assembly_done = 1;
            % ---
        end
    end

    % --- Methods
    methods
        function postpro(obj)
            % ---
            z_coil = 0;
            % ---
            obj.z_coil = z_coil;
        end
    end
end