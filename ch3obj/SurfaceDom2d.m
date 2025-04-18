%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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
        assembly_done = 0
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
            setup@SurfaceDom(obj);
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
            reset@SurfaceDom(obj);
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
            % ---
            obj.build_done = 1;
            % ---
        end
    end
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@SurfaceDom(obj);
            % ---
        end
    end
end
