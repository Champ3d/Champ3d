%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalDom < Xhandle
    properties
        id
        dom
        to_be_rebuild
    end
    % ---
    properties
        parent_model
        parent_mesh
        dom2d_collection
        id_dom2d
        dom3d_collection
        id_dom3d
    end
    % ---
    properties(Access = private, Hidden)

    end
    % ---

    % --- Contructor
    methods
        function obj = PhysicalDom(args)
            obj = obj@Xhandle;
            args = obj.getargs(args);
            obj <= args;
        end
    end

    % --- Methods
    methods
        function coef_array = call_coefficient(obj,args)
            arguments
                obj
                % ---
                args.coef_name = []
            end
        end
    end
end