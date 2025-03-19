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
classdef FEMM2dCoil < Xhandle
    properties
        id_coil
        id_wire
        id_circuit = []
        nb_turn = 1
        % ---
        i
        j
        v
        z
        % ---
        id_material
        parent_model
    end
    properties (Hidden)
    end
    % --- Constructor
    methods
        function obj = FEMM2dCoil()
            obj@Xhandle;
        end
    end
    % --- Methods/protected
    methods (Access = public)

    end
    % --- Methods/protected
    methods (Access = protected)

    end
end