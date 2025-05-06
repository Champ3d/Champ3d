%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef FEMM2dBC < Xhandle
    properties
        bc_type
        a0 = 0
        a1 = 0
        a2 = 0
        phi = 0
        mur = 0
        sigma = 0
        c0 = 0
        c1 = 0
        ia = 0
        oa = 0
        % ---
        parent_model
    end
    % --- Constructor
    methods
        function obj = FEMM2dBC()
            obj@Xhandle;
        end
    end
    % --- Methods/protected
    methods (Access = public)
        % -----------------------------------------------------------------
        function setup(obj,id_bc)
            bc_femm_id = obj.get_bc_femm_id;
            % -------------------------------------------------------------
            mi_deleteboundprop(id_bc);
            mi_addboundprop(id_bc, obj.a0, obj.a1, obj.a2, obj.phi, ...
                            obj.mur, obj.sigma, obj.c0, obj.c1, ...
                            bc_femm_id, obj.ia, obj.oa);
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = private)
        function bc_femm_id = get_bc_femm_id(obj)
            switch obj.bc_type
                case 'fixed_a'
                    bc_femm_id = 0;
                case 'sibc'
                    bc_femm_id = 1;
                case 'mixed'
                    bc_femm_id = 2;
                case 'dual_image'
                    bc_femm_id = 3;
                case 'periodic'
                    bc_femm_id = 4;
                case 'anti_periodic'
                    bc_femm_id = 5;
                case 'periodic_airgap'
                    bc_femm_id = 6;
                case 'anti_periodic_airgap'
                    bc_femm_id = 7;
                case 'open'
                    bc_femm_id = 2;
            end
        end
    end
end