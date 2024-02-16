%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Coefficient
    properties
        f
        depend_on
        varargin_list
        vectorized
        % ---
        value
    end

    % --- Contructor
    methods
        function obj = Coefficient(args)
            arguments
                args.f
                args.depend_on
                args.varargin_list
                args.vectorized
            end
            obj <= args;
        end
    end
end