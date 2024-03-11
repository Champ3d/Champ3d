%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SolidCoilAphi < Econductor

    % --- Contructor
    methods
        function obj = SolidCoilAphi()
            obj@Econductor;
        end
    end
    
    % --- setup
    methods
        function setup(obj)
            if ~obj.setup_done
                % ---
                setup@Econductor(obj);
                % ---
                if isnumeric(obj.sigma)
                    obj.sigma = Parameter('f',obj.sigma);
                end
                % ---
                obj.setup_done = 1;
            end
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