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
classdef FEMM2dIsCoil < FEMM2dCoil
    properties
        
    end
    % --- Constructor
    methods
        function obj = FEMM2dIsCoil(args)
            arguments
                args.id_wire
                args.id_circuit
                args.nb_turn
            end
            % ---
            obj@FEMM2dCoil;
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_coil)
            obj.id_material = obj.id_wire;
            cirobj = obj.parent_model.circuit.(obj.id_circuit);
            wireobj = obj.parent_model.material.(obj.id_wire);
            cirobj.coil_wire_type = wireobj.wire_type;
        end
        % -----------------------------------------------------------------
        function val = get_quantity(obj,quantity)
            % get integral quantities
            arguments
                obj
                quantity {mustBeMember(quantity,{...
                'int_AxJ_ds',...
                'int_A_ds',...
                'magnetic_energy',...
                'magnetic_coenergy',...
                'lamination_losses',...
                'resistive losses',...
                'cross_section_area',...
                'total_losses',...
                'int_J_ds',...
                'volume'})}
            end
            % ---
            if nargin > 1
                id_quantity = obj.get_id_quantity(quantity);
                % ---
                mi_loadsolution;
                mo_clearblock;
                mo_groupselectblock(obj.in_group);
                val = mo_blockintegral(id_quantity);
                mo_clearblock;
            else
                val = 0;
            end
        end
    end
    % --- Methods/protected
    methods (Access = protected)
        
    end
end