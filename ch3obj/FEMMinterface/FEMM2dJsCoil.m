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
classdef FEMM2dJsCoil < FEMM2dCoil
    properties
        
    end
    % --- Constructor
    methods
        function obj = FEMM2dJsCoil(args)
            arguments
                args.id_wire
                args.j
            end
            % ---
            obj@FEMM2dCoil;
            % ---
            obj <= args;
            % ---
            obj.id_circuit = [];
            obj.nb_turn = 1;
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_coil)
            % ---
            obj.id_material = [obj.id_wire '_' id_coil];
            % ---
            wireobj = obj.parent_model.material.(obj.id_wire);
            % ---
            wireobj.get_id_wire_type;
            % -------------------------------------------------------------
            mi_deletematerial(obj.id_material);
            mi_addmaterial(obj.id_material,...
                           1,...
                           1,...
                           0,...
                           obj.j/1e6,...
                           wireobj.sigma/1e6,...
                           0,...
                           0,...
                           0,...
                           wireobj.id_wire_type,...
                           0,...
                           0,...
                           wireobj.nb_strand,...
                           wireobj.wire_diameter);
        end
    end
    % --- Methods/protected
    methods (Access = protected)
        
    end
end