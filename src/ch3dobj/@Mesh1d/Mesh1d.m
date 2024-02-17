%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh1d < Xhandle

    % --- Properties
    properties
        info = []
        dom = []
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = Mesh1d(args)
            arguments
                args.info = 'no_info'
                args.data = []
            end
            % ---
            obj.info = args.info;
            obj.dom = args.data;
        end
    end

    % --- Methods
    methods
        % ---
        function obj = add_line1d(obj,args)
            arguments
                obj
                % ---
                args.id char
                args.len {mustBeNumeric}
                args.dtype = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % --- 
            argu = f_to_namedarg(args);
            line = Line1d(argu{:});
            % ---
            obj.dom.(args.id) = line;
        end
        % ---

    end
end











