%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef StrandedCoilAphi < Xhandle

    % --- Contructor
    methods
        function obj = StrandedCoilAphi()
            obj@Xhandle;
        end
    end

    % --- Methods
    methods
        function z_coil = get_zcoil(obj)
            % ---
            z_coil = 0;
            % ---
            obj.z_coil = z_coil;
        end
    end

end