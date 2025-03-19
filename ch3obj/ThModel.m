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
        parent_mesh
        % ---
        thconductor
        thcapacitor
        convection
        radiation
        % ---
        ps
        pv
        % ---
        Temp0 = 0
        % ---
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','timesystem','Temp0'};
        end
    end
    % --- Constructor
    methods
        function obj = ThModel(args)
            arguments
                args.parent_mesh
                args.timesystem
                args.Temp0
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
            f_initobj(obj,'property_name','field',...
                     'field_name',{'tempv','temps'}, ...
                     'init_value',args.Temp0);
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
                phydom = ThconductorTemp(argu{:});
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
                phydom = ThcapacitorTemp(argu{:});
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
                phydom = ThconvectionTemp(argu{:});
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
                phydom = ThPsTemp(argu{:});
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
                phydom = ThPvTemp(argu{:});
            end
            % ---
            obj.pv.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        %function add_thbc(obj)
        %end
    end

    % --- Methods
    methods
        function setup(obj)
            nb_elem = obj.parent_mesh.nb_elem;
            nb_face = obj.parent_mesh.nb_face;
            % ---
            obj.field.tempv = zeros(1,nb_elem) + obj.Temp0;
        end
    end
end