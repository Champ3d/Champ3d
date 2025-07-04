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
                phydom = Econductor(argu{:});
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
                phydom = Airbox(argu{:});
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
                phydom = Nomesh(argu{:});
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
                args.id_dom2d 
                args.id_dom3d
                args.sigma
                args.mur
                args.r_ht
                args.r_et
            end
            % ---
            args.parent_model = obj;
            % ---
            argu = f_to_namedarg(args,'for','Sibcjw');
            % ---
            if isa(obj,'FEM3dAphijw')
                phydom = Sibcjw(argu{:});
                obj.sibc.(args.id) = phydom;
            else
                f_fprintf(1,'Sibc',0,'is only supported with',1,'FEM3dAphijw',0,'(<ver.2025.05) ! \n');
            end
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
                phydom = Bsfield(argu{:});
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
                args.coil_obj {mustBeA(args.coil_obj,'Coil')}
            end
            % ---
            obj.coil.(args.id) = args.coil_obj;
            obj.coil.(args.id).id = args.id;
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
                phydom = Mconductor(argu{:});
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
                phydom = PMagnet(argu{:});
            end
            % ---
            obj.pmagnet.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        % function add_ltime(obj,args)
        %     arguments
        %         obj
        %         % ---
        %         args.ltime_array {mustBeNumeric} = []
        %         args.t0 {mustBeNumeric} = 0
        %         args.t_end {mustBeNumeric} = 0
        %         args.dnum {mustBeNumeric} = 1
        %         args.ltime_obj {mustBeA(args.ltime_obj,'LTime')}
        %     end
        %     % ---
        %     if isfield(args,'ltime_obj')
        %         ltime_obj = args.ltime_obj;
        %     else
        %         argu = f_to_namedarg(args,'for','LTime');
        %         ltime_obj = LTime(argu{:});
        %     end
        %     % ---
        %     obj.ltime = ltime_obj;
        % end
        % -----------------------------------------------------------------
        % function add_movingframe(obj,args)
        %     arguments
        %         obj
        %         % ---
        %         args.move_type {mustBeMember(args.move_type,{'linear','rotational'})}
        %         args.lin_dir
        %         args.lin_step
        %         args.rot_origin
        %         args.rot_axis
        %         args.rot_angle
        %         args.movingframe_obj {mustBeA(args.movingframe_obj,'MovingFrame')}
        %     end
        %     % ---
        %     if isfield(args,'movingframe_obj')
        %         movingframe_obj = args.movingframe_obj;
        %     elseif f_strcmpi(args.move_type,'linear')
        %         argu = f_to_namedarg(args,'for','LinearMovingFrame');
        %         movingframe_obj = LinearMovingFrame(argu{:});
        %     elseif f_strcmpi(args.move_type,'rotational')
        %         argu = f_to_namedarg(args,'for','RotationalMovingFrame');
        %         movingframe_obj = RotationalMovingFrame(argu{:});
        %     end
        %     % ---
        %     obj.moving_frame = movingframe_obj;
        % end
        % -----------------------------------------------------------------
    end
end