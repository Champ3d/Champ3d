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
        end
    end

    % --- Utility Methods
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
                phydom = Thconductor(argu{:});
            end
            % ---
            obj.thconductor.(args.id) = phydom;
            % ---
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
                phydom = Thcapacitor(argu{:});
            end
            % ---
            obj.thcapacitor.(args.id) = phydom;
            % ---
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
                phydom = Thconvection(argu{:});
            end
            % ---
            obj.convection.(args.id) = phydom;
            % ---
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
                phydom = ThPs(argu{:});
            end
            % ---
            obj.ps.(args.id) = phydom;
            % ---
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
                phydom = ThPv(argu{:});
            end
            % ---
            obj.pv.(args.id) = phydom;
            % ---
        end
        % -----------------------------------------------------------------
    end
end