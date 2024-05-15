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
        it = 0
        time_array
    end

    % --- Properties
    properties (Access = private, Hidden)
        nbdigit = 10;
    end

    % --- Dependent Properties
    properties (Dependent = true)
        it_max
        time_now
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'time_array','t0','t_end','dnum'};
        end
    end
    % --- Constructors
    methods
        function obj = LTime(args)
            arguments
                args.time_array {mustBeNumeric}
                args.t0 {mustBeNumeric}
                args.t_end {mustBeNumeric}
                args.dnum {mustBeNumeric}
            end
            obj = obj@Xhandle;
            % ---
            if isfield(args,'time_array')
                if ~isempty(args.time_array)
                    obj.time_array = round(args.time_array,obj.nbdigit); % !!!
                end
            end
            % ---
            if isempty(obj.time_array)
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
                obj.time_array = [t0, t0 + cumsum((t_end-t0)/dnum .* ones(1,dnum))];
                % ---
                obj.time_array = round(obj.time_array,obj.nbdigit); % !!!
                obj.time_array = uniquetol(obj.time_array); % !!!
                % ---
            end
            % ---
        end
    end

    % --- Methods
    methods
        function val = get.time_now(obj)
            if obj.it > 0
                val = obj.time_array(obj.it);
            else
                val = -inf;
            end
        end
        % ---
        function val = get.it_max(obj)
            val = length(obj.time_array);
        end
    end
end