%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef IsCoilAphi < Xhandle
    
    % --- Contructor
    methods
        function obj = IsCoilAphi()
            obj@Xhandle;
        end
    end

    % --- setup
    methods
        function setup(obj)
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            obj.matrix.i_coil = obj.i_coil.get_on(dom);
            % ---
        end
    end
end