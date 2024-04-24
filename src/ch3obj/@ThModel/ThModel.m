%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThModel < Xhandle
    properties
        id
        % ---
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
        ltime
        Temp0 = 0
        % ---
        matrix
        fields
        dof
        % ---
        build_done = 0
        assembly_done = 0
        solve_done = 0
    end

    % --- Constructor
    methods
        function obj = ThModel(args)
            arguments
                args.id
                % ---
                args.parent_mesh
                args.timesystem
                args.Temp0
            end
            % ---
            obj@Xhandle;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.init('property_name','fields',...
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
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dTemp')
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
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dTemp')
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
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dTemp')
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
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dTemp')
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
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dTemp')
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
            obj.fields.tempv = zeros(1,nb_elem) + obj.Temp0;
        end
    end
end