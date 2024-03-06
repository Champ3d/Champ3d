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
        % ---
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
        % ---
        matrix
        fields
        dof
    end

    % --- Constructor
    methods
        function obj = EmModel(args)
            arguments
                args.id = 'no_id'
                % ---
                args.parent_mesh = []
                args.frequency = 0
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
            phydom = Econductor(args);
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
            phydom = Airbox(args);
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
            phydom = Nomesh(args);
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
            phydom = Sibc(args);
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
            phydom = Bsfield(args);
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
                args.j_coil = 0
                args.i_coil = 0
                args.v_coil = 0
                args.nb_turn = 1
                args.cs_area = 1
            end
            % ---
            args.parent_model = obj;
            % ---
            phydom = CloseJsCoil(args);
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
            phydom = CloseJsCoil(args);
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
            phydom = Mconductor(args);
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
            phydom = PMagnet(args);
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