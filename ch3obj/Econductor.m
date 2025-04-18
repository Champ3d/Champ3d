%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Econductor < PhysicalDom

    properties
        sigma = 0
    end
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end

    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','sigma'};
        end
    end
    % --- Contructor
    methods
        function obj = Econductor(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.sigma
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Econductor.setup(obj);
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
            setup@PhysicalDom(obj);
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
            reset@PhysicalDom(obj);
        end
    end
    methods
        function build(obj)
            % ---
            Econductor.setup(obj);
            % ---
            build@PhysicalDom(obj);
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
            assembly@PhysicalDom(obj);
            % ---
            if obj.assembly_done
                return
            end
            % ---
            obj.assembly_done = 1;
            % ---
        end
    end
end