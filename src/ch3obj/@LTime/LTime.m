%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTime < Xhandle

    % --- Properties
    properties
        lit = 0
        ltime_array
    end

    % --- Dependent Properties
    properties (Dependent = true)
        ltime_now
    end

    % --- Constructors
    methods
        function obj = LTime(args)
            arguments
                args.ltime_array {mustBeNumeric}
                args.t0 {mustBeNumeric}
                args.t_end {mustBeNumeric}
                args.dnum {mustBeNumeric}
            end
            obj = obj@Xhandle;
            % ---
            if isfield(args,'ltime_array')
                obj.ltime_array = args.ltime_array;
            else
                % ---
                t0 = 0;
                t_end = 0;
                dnum = 1;
                % ---
                if isfield(args,'t0')
                    t0 = args.t0;
                end
                if isfield(args,'t_end')
                    t_end = args.t_end;
                end
                if isfield(args,'dnum')
                    dnum = args.dnum;
                end
                % ---
                obj.ltime_array = [t0, t0 + cumsum((t_end-t0)/dnum .* ones(1,dnum))];
            end
            % ---
        end
    end

    % --- Methods
    methods
        function val = get.ltime_now(obj)
            if obj.lit > 0
                val = obj.ltime_array(obj.lit);
            else
                val = -inf;
            end
        end
    end

    % --- Methods
    methods (Access = public)
        % ---
        function objx = uplus(obj)
            objx = copy(obj);
        end
        % ---
        function objx = ctranspose(obj)
            objx = copy(obj);
        end
        % ---
    end
end