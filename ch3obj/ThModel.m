%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThModel < PhysicalModel
    properties
        % ---
        thconductor
        thcapacitor
        convection
        radiation
        % ---
        ps
        pv
        % ---
        T0 = 0
        % ---
    end
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','timesystem','T0'};
        end
    end
    % --- Constructor
    methods
        function obj = ThModel(args)
            arguments
                args.parent_mesh
                args.timesystem
                args.T0
            end
            % ---
            obj@PhysicalModel;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            ThModel.setup(obj);
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
            setup@PhysicalModel(obj);
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
            reset@PhysicalModel(obj);
        end
    end
    methods
        function build(obj)
            % ---
            ThModel.setup(obj);
            % ---
            build@PhysicalModel(obj);
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
            assembly@PhysicalModel(obj);
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
        % -----------------------------------------------------------------
        function add_thconductor(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.lambda = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','Thconductor');
            % ---
            if isa(obj,'FEM3dTherm')
                phydom = ThconductorTherm(argu{:});
            end
            % ---
            obj.thconductor.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_thcapacitor(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.rho = 0
                args.cp = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','Thcapacitor');
            % ---
            if isa(obj,'FEM3dTherm')
                phydom = ThcapacitorTherm(argu{:});
            end
            % ---
            obj.thcapacitor.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_convection(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.h = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','Thconvection');
            % ---
            if isa(obj,'FEM3dTherm')
                phydom = ThconvectionTherm(argu{:});
            end
            % ---
            obj.convection.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_ps(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.ps = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','ThPs');
            % ---
            if isa(obj,'FEM3dTherm')
                phydom = ThPsTherm(argu{:});
            end
            % ---
            obj.ps.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_pv(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.pv = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','ThPv');
            % ---
            if isa(obj,'FEM3dTherm')
                phydom = ThPvTherm(argu{:});
            end
            % ---
            obj.pv.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
    end
end