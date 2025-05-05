%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh1d < Xhandle

    % --- Properties
    properties
        dom = []
    end

    properties (Access = private)
        setup_done = 0
    end

    properties
        dependent_obj = []
        defining_obj = []
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = Mesh1d()
            obj@Xhandle;
            Mesh1d.setup(obj);
        end
    end

    methods (Static)
        function setup(obj)
            if obj.setup_done
                return
            end
        end
    end

    methods (Access = public)
        function reset(obj)
            % ---
            obj.setup_done = 0;
            Mesh1d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
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
                args.dtype {mustBeMember(args.dtype,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % --- 
            argu = f_to_namedarg(args,'for','Line1d');
            line = Line1d(argu{:});
            % ---
            obj.dom.(args.id) = line;
            % ---
            line.is_defining_obj_of(obj);
            % ---
        end
        % ---
    end
end











