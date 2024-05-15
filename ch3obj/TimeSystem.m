%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef TimeSystem < Xhandle

    % --- Properties
    properties
        it = 1 % !!!
        time_array
        ltime
    end
    % ---
    properties (Dependent)
        time_now
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
        function val = get.time_now(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            if obj.it > 0
                val = obj.time_array(obj.it);
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
            val = min(obj.time_array);
        end
        % ---
        function val = get.t_end(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            val = max(obj.time_array);
        end
        % ---
    end
    % --- Methods
    methods
        function add_ltime(obj,args)
            arguments
                obj
                args.id = 'no_id'
                args.time_array {mustBeNumeric} = []
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
                elseif obj.ltime.(ltime_{i}).time_now > obj.time_now
                    obj.ltime.(ltime_{i}).it = obj.ltime.(ltime_{i}).it - 1;
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function init(obj)
            ltime_ = fieldnames(obj.ltime);
            % ---
            time_array_ = [];
            for i = 1:length(ltime_)
                time_array_ = [time_array_ obj.ltime.(ltime_{i}).time_array];
            end
            % ---
            time_array_ = sort(uniquetol(time_array_));
            % ---
            obj.time_array = time_array_;
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