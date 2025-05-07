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

classdef EmModel < PhysicalModel
    properties
        frequency = 0
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
    end
    properties (Dependent)
        jome
    end
    % --- Constructor
    methods
        function obj = EmModel()
            obj@PhysicalModel;
        end
    end
    % --- get
    methods
        function val = get.jome(obj)
            val = 1j*2*pi*obj.frequency;
        end
    end
    % --- Utility Methods
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
                args.ltime_obj {mustBeA(args.ltime_obj,'LTime')}
            end
            % ---
            if isfield(args,'ltime_obj')
                ltime_obj = args.ltime_obj;
            else
                argu = f_to_namedarg(args,'for','LTime');
                ltime_obj = LTime(argu{:});
            end
            % ---
            obj.ltime = ltime_obj;
        end
        % -----------------------------------------------------------------
        function add_movingframe(obj,args)
            arguments
                obj
                % ---
                args.move_type {mustBeMember(args.move_type,{'linear','rotational'})}
                args.lin_dir
                args.lin_step
                args.rot_origin
                args.rot_axis
                args.rot_angle
                args.movingframe_obj {mustBeA(args.movingframe_obj,'MovingFrame')}
            end
            % ---
            if isfield(args,'movingframe_obj')
                movingframe_obj = args.movingframe_obj;
            elseif f_strcmpi(args.move_type,'linear')
                argu = f_to_namedarg(args,'for','LinearMovingFrame');
                movingframe_obj = LinearMovingFrame(argu{:});
            elseif f_strcmpi(args.move_type,'rotational')
                argu = f_to_namedarg(args,'for','RotationalMovingFrame');
                movingframe_obj = RotationalMovingFrame(argu{:});
            end
            % ---
            obj.moving_frame = movingframe_obj;
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
            argu = f_to_namedarg(args,'for','Econductor');
            % ---
            if isa(obj,'FEM3dAphi')
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
            argu = f_to_namedarg(args,'for','Airbox');
            % ---
            if isa(obj,'FEM3dAphi')
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
            argu = f_to_namedarg(args,'for','Nomesh');
            % ---
            if isa(obj,'FEM3dAphi')
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
            argu = f_to_namedarg(args,'for','Sibc');
            % ---
            if isa(obj,'FEM3dAphi')
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
                if ~isfield(obj.parent_mesh.dom,'whole_mesh_dom')
                    obj.parent_mesh.add_whole_mesh_dom;
                end
                args.id_dom3d = 'whole_mesh_dom';
            end
            % ---
            argu = f_to_namedarg(args,'for','Bsfield');
            % ---
            if isa(obj,'FEM3dAphi')
                phydom = BsfieldAphi(argu{:});
            end
            % ---
            obj.bsfield.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_embc(obj,args)
            % --- XTODO - other bc types
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
            %argu = f_to_namedarg(args,'with_only',validargs);
            % ---
            if isa(obj,'FEM3dAphi')
                % ---
                coil_model = [coil_model 'Aphi'];
                % ---
                argu = f_to_namedarg(args,'for',coil_model);
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
            argu = f_to_namedarg(args,'for','Mconductor');
            % ---
            if isa(obj,'FEM3dAphi')
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
            argu = f_to_namedarg(args,'for','PMagnet');
            % ---
            if isa(obj,'FEM3dAphi')
                phydom = PMagnetAphi(argu{:});
            end
            % ---
            obj.pmagnet.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
    end
end