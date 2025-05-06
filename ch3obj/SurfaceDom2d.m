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

classdef SurfaceDom2d < SurfaceDom

    % --- Properties
    properties
        parent_mesh
        gid_face
        defined_on
        condition
    end

    % --- subfields to build
    properties
        
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {};
        end
    end
    % --- Constructors
    % --- XTODO
    methods
        function obj = SurfaceDom2d()
            % ---
            obj@SurfaceDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            SurfaceDom2d.setup(obj);
            % ---
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
            setup@SurfaceDom(obj);
            % --- XTODO
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % reset super
            reset@SurfaceDom(obj);
            % ---
            obj.setup_done = 0;
            SurfaceDom2d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            SurfaceDom2d.setup(obj);
            % ---
            build@SurfaceDom(obj);
            % ---
            if obj.build_done
                return
            end
            % --- XTODO
            % obj.build_defining_obj;
            % ---
            obj.build_done = 1;
            % ---
        end
    end
end
