%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEMM2dVdom < Xhandle
    properties
        id_material = []
        id_coil = []
        id_draw
        choosed_by
        mesh_size
        auto_pm_direction = []
        pm_direction = []
        % ---
        id_group = 0
        parent_model
    end
    properties (Hidden)
        is_material = 0
        is_pmagnet = 0
        is_coil = 0
    end
    properties (Dependent)
        quantity
    end
    % --- Constructor
    methods
        function obj = FEMM2dVdom()
            obj@Xhandle
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_dom)
            arguments
                obj
                id_dom
            end
            % --- check up
            if ~isempty(obj.id_coil)
                list_ = fieldnames(obj.parent_model.coil);
                if any(f_strcmpi(obj.id_coil,list_))
                    obj.id_material = [];
                    obj.is_material = 0;
                    obj.is_pmagnet = 0;
                    obj.is_coil = 1;
                else
                    error([obj.id_coil 'does not exist in coil list']);
                end
            elseif ~isempty(obj.id_material)
                list_ = fieldnames(obj.parent_model.material);
                if any(f_strcmpi(obj.id_material,list_))
                    obj.id_coil = [];
                    obj.is_coil = 0;
                    obj.is_material = 1;
                    obj.is_pmagnet = 0;
                    for i = 1:length(list_)
                        if f_strcmpi(obj.id_material,list_{i})
                            if isa(obj.parent_model.material.(list_{i}),'FEMM2dPMagnet')
                                obj.is_material = 0;
                                obj.is_pmagnet = 1;
                                break
                            end
                        end
                    end
                else
                    error([obj.id_material 'does not exist in material list']);
                end
            else
                error('id_material or id_coil must be defined');
            end
            %--------------------------------------------------------------
            [px, py] = obj.get_choosed_point;
            % ---
            id_groupe_ = [id_dom '_dom'];
            obj.id_group = f_str2code(id_groupe_,'code_type','integer');
            %--------------------------------------------------------------
            mi_clearselected;
            mi_addblocklabel(px,py);
            mi_selectlabel(px,py);
            mi_setgroup(obj.id_group);
            mi_clearselected;
            %--------------------------------------------------------------
            if obj.is_material
                obj.setup_material;
            elseif obj.is_pmagnet
                obj.setup_pmagnet;
            elseif obj.is_coil
                obj.setup_coil;
            end
        end
        % -----------------------------------------------------------------
        function setup_material(obj)
            mi_clearselected;
            mi_selectgroup(obj.id_group);
            mi_setblockprop(obj.id_material,0,obj.mesh_size,[],...
                            0,obj.id_group,0);
            mi_clearselected;
        end
        % -----------------------------------------------------------------
        function setup_pmagnet(obj)
            if ~isempty(obj.auto_pm_direction)
                obj.pm_direction = obj.orientation + obj.auto_pm_direction;
            end
            mi_clearselected;
            mi_selectgroup(obj.id_group);
            mi_setblockprop(obj.id_material,...
                            0,obj.mesh_size,[],...
                            obj.pm_direction,obj.id_group,0);
            mi_clearselected;
        end
        % -----------------------------------------------------------------
        function setup_coil(obj)
            mi_clearselected;
            mi_selectgroup(obj.id_group);
            mi_setblockprop(obj.parent_model.coil.(obj.id_coil).id_material,...
                            0,obj.mesh_size,...
                            obj.parent_model.coil.(obj.id_coil).id_circuit,...
                            0,obj.id_group,...
                            obj.parent_model.coil.(obj.id_coil).nb_turn);
            mi_clearselected;
        end
    end
    % --- Methods/get
    methods
        % -----------------------------------------------------------------
        function val = get.quantity(obj)
            % get integral quantities
            try
                mi_loadsolution;
            catch
                obj.parent_model.open;
            end
            % ---
            mo_clearblock;
            mo_groupselectblock(obj.id_group);
            % ---
            quan_ = {'int_AxJ_ds',...
                     'int_A_ds',...
                     'magnetic_energy',...
                     'magnetic_coenergy',...
                     'lamination_losses',...
                     'resistive_losses',...
                     'area',...
                     'total_losses',...
                     'int_J_ds',...
                     'volume'};
            for i = 1:length(quan_)
                val.(quan_{i}) = mo_blockintegral(obj.get_id_quantity(quan_{i}));
            end
            mo_clearblock;
            % ---
            val.resistive_losses = real(val.resistive_losses);
            val.total_losses = real(val.total_losses);
            val.loss_density = val.total_losses / val.volume;
            % ---
        end
    end
    % --- Methods/protected
    methods (Access = protected)
    end
    % --- Methods/private
    methods (Access = private)
        function [px, py] = get_choosed_point(obj)
            % ---
            def_in   = obj.id_draw;
            drawlist = fieldnames(obj.parent_model.draw);
            boxlist  = fieldnames(obj.parent_model.box);
            if any(f_strcmpi(def_in,drawlist))
                domobj = obj.parent_model.draw.(def_in);
            elseif any(f_strcmpi(def_in,boxlist))
                domobj = obj.parent_model.box.(def_in);
            else
                warning([def_in ' is not found in draw or box']);
                return
            end
            % -------------------------------------------------------------
            switch lower(obj.choosed_by)
                case {'center','c'}
                    px = domobj.center(1);
                    py = domobj.center(2);
                case {'bottomleft','bl'}
                    px = domobj.bottomleft(1);
                    py = domobj.bottomleft(2);
                case {'bottomright','br'}
                    px = domobj.bottomright(1);
                    py = domobj.bottomright(2);
                case {'topleft','tl'}
                    px = domobj.topleft(1);
                    py = domobj.topleft(2);
                case {'topright','tr'}
                    px = domobj.topright(1);
                    py = domobj.topright(2);
                case {'bottom','b'}
                    px = domobj.bottom(1);
                    py = domobj.bottom(2);
                case {'top','t'}
                    px = domobj.top(1);
                    py = domobj.top(2);
                case {'right','r'}
                    px = domobj.right(1);
                    py = domobj.right(2);
                case {'left','l'}
                    px = domobj.left(1);
                    py = domobj.left(2);
            end
        end
        % ---
        function id_quantity = get_id_quantity(obj,quantity)
            switch quantity
                case 'int_AxJ_ds'
                    id_quantity = 0;
                case 'int_A_ds'
                    id_quantity = 1;
                case 'magnetic_energy'
                    id_quantity = 2;
                case 'magnetic_coenergy'
                    id_quantity = 17;
                case 'lamination_losses'
                    id_quantity = 3;
                case 'resistive_losses'
                    id_quantity = 4;
                case 'area'
                    id_quantity = 5;
                case 'total_losses'
                    id_quantity = 6;
                case 'int_J_ds'
                    id_quantity = 7;
                case 'volume'
                    id_quantity = 10;
            end
        end
    end
end