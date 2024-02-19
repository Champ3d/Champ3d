%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mconductor < PhysicalDom
    properties
        mu_r = 1
    end

    % --- Contructor
    methods
        function obj = Mconductor(args)
            obj = obj@PhysicalDom(args);
            obj <= args;
            if isnumeric(obj.mu_r)
                obj.mu_r = Parameter('f',obj.mu_r);
            end
        end
    end
end