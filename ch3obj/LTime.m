%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTime < Xhandle

    % --- Properties
    properties
        parent_model
        it = 0
        t_array
    end

    % --- Properties
    properties (Access = private, Hidden)
        nbdigit = 10;
    end

    % --- Dependent Properties
    properties (Dependent = true)
        it_max
        t_now
        t_end
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
                args.t_array {mustBeNumeric}
                args.t0 {mustBeNumeric}
                args.t_end {mustBeNumeric}
                args.dnum {mustBeNumeric}
            end
            obj = obj@Xhandle;
            % ---
            if isfield(args,'t_array')
                if ~isempty(args.t_array)
                    obj.t_array = round(args.t_array, obj.nbdigit); % !!!
                end
            end
            % ---
            if isempty(obj.t_array)
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
                obj.t_array = [t0, t0 + cumsum((t_end-t0)/dnum .* ones(1,dnum))];
                % ---
                obj.t_array = round(obj.t_array,obj.nbdigit); % !!!
                obj.t_array = uniquetol(obj.t_array); % !!!
                % ---
            end
            % ---
        end
    end

    % --- get
    methods
        function val = get.t_now(obj)
            if obj.it > 0
                if obj.it <= obj.it_max
                    val = obj.t_array(obj.it);
                else
                    val = +Inf;
                end
            else
                val = -Inf;
            end
        end
        % ---
        function val = get.t_end(obj)
            val = obj.t_array(end);
        end
        % ---
        function val = get.it_max(obj)
            val = length(obj.t_array);
        end
    end
    % --- methods
    methods
        function i = next_it(obj,t)
            i = find(t <= obj.t_array,1);
            if isempty(i)
                i = obj.back_it(t);
            end
        end
        function i = back_it(obj,t)
            i = length(obj.t_array) - find(t >= obj.t_array(end:-1:1),1) + 1;
            if isempty(i)
                i = obj.next_it(t);
            end
        end
        function t = t_at(obj,it)
            t = obj.t_array(it);
        end
    end
end