%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Econductor < PhysicalDom
    properties
        sigma = 0
    end

    % --- Contructor
    methods
        function obj = Econductor(args)
            obj = obj@PhysicalDom(args);
            obj <= args;
            if isnumeric(obj.sigma)
                obj.sigma = Parameter('f',obj.sigma);
            end
        end
    end
end