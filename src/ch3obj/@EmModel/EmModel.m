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
        id
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
        ltime
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
                args.id
                args.parent_mesh
                args.frequency
                args.ltime {mustBeMember(args.ltime,'LTime')}
            end
            % ---
            obj@Xhandle;
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
            if isempty(obj.ltime)
                obj.ltime = LTime;
            end
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function add_ltime(obj,args)
            arguments
                obj
                % ---
                args.ltime_array {mustBeNumeric} = []
                args.t0 {mustBeNumeric} = 0
                args.t_end {mustBeNumeric} = 0
                args.dnum {mustBeNumeric} = 1
                args.ltime_obj {mustBeMember(args.ltime_obj,'LTime')}
            end
            % ---
            if isfield(args,'ltime_obj')
                ltime_obj = args.ltime_obj;
            else
                argu = f_to_namedarg(args,'with_out','ltime_obj');
                ltime_obj = LTime(argu{:});
            end
            % ---
            obj.ltime = ltime_obj;
        end
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
            if isa(obj,'FEM3dAphijw')
                phydom = AirboxAphi(argu{:});
            end
            % ---
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
            if isa(obj,'FEM3dAphijw')
                phydom = NomeshAphi(argu{:});
            end
            % ---
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
                args.mur = 1
                args.r_ht = []
                args.r_et = []
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args);
            % ---
            if isa(obj,'FEM3dAphijw')
                phydom = SibcAphijw(argu{:});
                %nomsh  = NomeshAphi('parent_model',args.parent_model, ...
                %                    'id_dom2d',args.id_dom2d,...
                %                    'id_dom3d',args.id_dom3d);
            end
            % ---
            obj.sibc.(args.id) = phydom;
            %obj.nomesh.(['nomesh_for_sibc_' args.id]) = nomsh;
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
            if isa(obj,'FEM3dAphijw')
                phydom = BsfieldAphi(argu{:});
            end
            % ---
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
                args.source_type {mustBeMember(args.source_type,{'current_fed','voltage_fed','current_density_fed'})}
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
            if any(f_strcmpi(coil_model,{'StrandedOpenJsCoil','StrandedCloseJsCoil'}))
                validargs = {'id','parent_model','id_dom2d','id_dom3d',...
                             'etrode_equation','connexion', ...
                             'cs_area','nb_turn','fill_factor',...
                             'j_coil','coil_mode'};
            elseif f_strcmpi(coil_model,'SolidOpenVsCoil')
                validargs = {'id','parent_model','id_dom2d','id_dom3d',...
                             'etrode_equation',...
                             'v_coil','coil_mode'};
            elseif f_strcmpi(coil_model,'SolidOpenIsCoil')
                validargs = {'id','parent_model','id_dom2d','id_dom3d',...
                             'etrode_equation',...
                             'i_coil','coil_mode'};
            end
            % ---
            argu = f_to_namedarg(args,'with_only',validargs);
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
            if isa(obj,'FEM3dAphijw')
                phydom = MconductorAphi(argu{:});
            end
            % ---
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
            if isa(obj,'FEM3dAphijw')
                phydom = PMagnetAphi(argu{:});
            end
            % ---
            obj.pmagnet.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function setup(obj)
            nb_elem = obj.parent_mesh.nb_elem;
            nb_face = obj.parent_mesh.nb_face;
            % ---
            obj.fields.av = sparse(3,nb_elem);
            obj.fields.bv = sparse(3,nb_elem);
            obj.fields.ev = sparse(3,nb_elem);
            obj.fields.phiv = sparse(3,nb_elem);
            obj.fields.phi = [];
            obj.fields.jv = sparse(3,nb_elem);
            obj.fields.pv = sparse(1,nb_elem);
            obj.fields.js = sparse(2,nb_face);
            obj.fields.ps = sparse(1,nb_face);
        end
    end
end