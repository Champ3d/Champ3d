%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SurfaceDom2d < SurfaceDom

    % --- Properties
    properties
        parent_mesh
        gid_face
        defined_on
        condition
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {};
        end
    end
    % --- Constructors
    % --- XTODO
    methods
        function obj = SurfaceDom2d()
            
        end
    end

end
