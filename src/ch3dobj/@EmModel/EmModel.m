%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef EmModel < Xhandle
    properties
        frequency = 0
        jome
        % ---
        parent_mesh
        % ---
        econductor
        mconductor
        pmagnet
        airbox
        nomesh
        coil
        bsfield
        sibc
        embc
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
        function obj = EmModel(args)
            arguments
                args.parent_mesh
                args.frequency
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
            obj.jome = 1j*2*pi*obj.frequency;
            % ---
            obj.init('property_name','fields',...
                     'field_name',{'bv','jv','hv','pv','av','phiv','tv','omev',...
                     'bs','js','hs','ps','as','phis','ts','omes'}, ...
                     'init_value',[]);
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function add_econductor(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.sigma = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dAphijw')
                phydom = EconductorAphi(argu{:});
            end
            % ---
            obj.econductor.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_airbox(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = Airbox(argu{:});
            obj.airbox.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_nomesh(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = Nomesh(argu{:});
            obj.nomesh.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_sibc(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.sigma = 0
                args.mur = 0
                args.r_ht = []
                args.r_et = []
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = Sibc(argu{:});
            obj.sibc.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_bsfield(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.bs = []
            end
            % ---
            args.parent_model = obj;
            % ---
            if isempty(args.id_dom3d)
                if ~isfield(obj.parent_mesh.dom,'default_domain')
                    obj.parent_mesh.add_default_domain;
                end
                args.id_dom3d = 'default_domain';
            end
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = Bsfield(argu{:});
            obj.bsfield.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_embc(obj,args)
        end
        % -----------------------------------------------------------------
        function add_coil(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.etrode_equation = []
                args.coil_type {mustBeMember(args.coil_type,{'stranded','solid'})}
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})} = 'tx'
                args.source_type {mustBeMember(args.source_type,'current_fed','voltage_fed','current_density_fed')}
                args.connexion {mustBeMember(args.connexion,{'serial','parallel'})}
                args.fill_factor = 1
                args.j_coil = 0
                args.i_coil = 0
                args.v_coil = 0
                args.nb_turn = 1
                args.cs_area = 1
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            coil_model = [];
            % ---
            if f_strcmpi(args.coil_type,'stranded')
                coil_model = [coil_model 'Stranded'];
            elseif f_strcmpi(args.coil_type,'solid')
                coil_model = [coil_model 'Solid'];
            end
            % ---
            if length(f_to_scellargin(args.etrode_equation)) == 1
                coil_model = [coil_model 'Close'];
            else
                coil_model = [coil_model 'Open'];
            end
            % ---
            if f_strcmpi(args.source_type,'current_fed')
                coil_model = [coil_model 'Is'];
                if f_strcmpi(args.coil_mode,'tx')
                    if isempty(args.i_coil)
                        error('#i_coil must be given !');
                    end
                end
            elseif f_strcmpi(args.source_type,'voltage_fed')
                coil_model = [coil_model 'Vs'];
                if f_strcmpi(args.coil_mode,'tx')
                    if isempty(args.v_coil)
                        error('#v_coil must be given !');
                    end
                end
            elseif f_strcmpi(args.source_type,'current_density_fed')
                coil_model = [coil_model 'Js'];
                if f_strcmpi(args.coil_mode,'tx')
                    if isempty(args.j_coil)
                        error('#j_coil must be given !');
                    end
                end
            end
            % ---
            coil_model = [coil_model 'Coil'];
            % ---
            if isa(obj,'FEM3dAphijw')
                % ---
                coil_model = [coil_model 'Aphi'];
                % ---
                phydom = feval(coil_model,argu{:});
            end
            % ---
            obj.coil.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_open_iscoil(obj,args)
        end
        % -----------------------------------------------------------------
        function add_close_iscoil(obj,args)
        end
        % -----------------------------------------------------------------
        function add_open_jscoil(obj,args)
        end
        % -----------------------------------------------------------------
        function add_close_jscoil(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.etrode_equation = []
                args.js = 1
                args.nb_turn = 1
                args.cs_area = 1
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = CloseJsCoil(argu{:});
            obj.coil.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_open_vscoil(obj,args)
        end
        % -----------------------------------------------------------------
        function add_close_vscoil(obj,args)
        end
        % -----------------------------------------------------------------
        function add_mconductor(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.mur = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = Mconductor(argu{:});
            obj.mconductor.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_pmagnet(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.br = []
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            phydom = PMagnet(argu{:});
            obj.pmagnet.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
    end

    % --- Methods/Abs
    methods
        function build(obj)
        end
        function solve(obj)
        end
        function postpro(obj)
        end
    end
end