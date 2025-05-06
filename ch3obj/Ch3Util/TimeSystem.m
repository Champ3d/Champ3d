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

classdef TimeSystem < Xhandle

    % --- Properties
    properties
        it = 1 % !!!
        t_array
        ltime
        lit
    end
    % ---
    properties (Dependent)
        t_now
        t0
        t_end
    end

    % ---
    properties (Access = private)
        init_done = 0
    end

    % --- Constructors
    methods
        function obj = TimeSystem()
            obj = obj@Xhandle;
            % ---
        end
    end
    % --- Methods
    methods
        % ---
        function val = get.t_now(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            if obj.it > 0
                val = obj.t_array(obj.it);
            else
                val = -inf;
            end
        end
        % ---
        function val = get.t0(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            val = min(obj.t_array);
        end
        % ---
        function val = get.t_end(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            val = max(obj.t_array);
        end
        % ---
    end
    % --- Methods
    methods
        function add_ltime(obj,args)
            arguments
                obj
                args.id = 'no_id'
                args.t_array {mustBeNumeric} = []
                args.t0 {mustBeNumeric} = 0
                args.t_end {mustBeNumeric} = 0
                args.dnum {mustBeNumeric} = 1
                args.ltime_obj {mustBeA(args.ltime_obj,'LTime')}
            end
            % ---
            if ~isfield(args,'ltime_obj')
                argu = f_to_namedarg(args,'for','LTime');
                ltime_ = LTime(argu{:});
            else
                ltime_ = args.ltime_obj;
            end
            % ---
            obj.ltime.(args.id) = ltime_;
            % ---
            obj.init;
        end
        % -----------------------------------------------------------------
        function increment(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            obj.it = obj.it + 1;
            % ---
            ltime_ = fieldnames(obj.ltime);
            % ---
            for i = 1:length(ltime_)
                obj.ltime.(ltime_{i}).it = obj.ltime.(ltime_{i}).it + 1;
                if obj.ltime.(ltime_{i}).it > obj.ltime.(ltime_{i}).it_max
                    obj.ltime.(ltime_{i}).it = obj.ltime.(ltime_{i}).it - 1;
                elseif obj.ltime.(ltime_{i}).t_now > obj.t_now
                    obj.ltime.(ltime_{i}).it = obj.ltime.(ltime_{i}).it - 1;
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function init(obj)
            ltime_ = fieldnames(obj.ltime);
            % ---
            t_array_ = [];
            for i = 1:length(ltime_)
                t_array_ = [t_array_ obj.ltime.(ltime_{i}).t_array];
            end
            % ---
            t_array_ = sort(uniquetol(t_array_));
            % ---
            for i = 1:length(ltime_)
                obj.lit{i} = floor(...
                    interp1(obj.ltime.(ltime_{i}).t_array,...
                            1:length(obj.ltime.(ltime_{i}).t_array),...
                            t_array_));
            end
            % ---
            obj.t_array = t_array_;
            % --- !!!
            obj.it = 0;
            % ---
            ltime_ = fieldnames(obj.ltime);
            % ---
            for i = 1:length(ltime_)
                obj.ltime.(ltime_{i}).it = 0;
            end
            % ---
            obj.init_done = 1;
        end
    end
end