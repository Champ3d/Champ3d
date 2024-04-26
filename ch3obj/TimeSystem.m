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
        git = 1 % !!!
        gtime_array
        ltime
    end
    % ---
    properties (Dependent)
        gtime_now
        gt0
        gt_end
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
        function val = get.gtime_now(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            if obj.git > 0
                val = obj.gtime_array(obj.git);
            else
                val = -inf;
            end
        end
        % ---
        function val = get.gt0(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            val = min(obj.gtime_array);
        end
        % ---
        function val = get.gt_end(obj)
            % ---
            if ~obj.init_done
                obj.init;
            end
            % ---
            val = max(obj.gtime_array);
        end
        % ---
    end
    % --- Methods
    methods
        function add_ltime(obj,args)
            arguments
                obj
                args.id = 'no_id'
                args.ltime_array {mustBeNumeric} = []
                args.t0 {mustBeNumeric} = 0
                args.t_end {mustBeNumeric} = 0
                args.dnum {mustBeNumeric} = 1
            end
            % ---
            argu = f_to_namedarg(args);
            % ---
            ltime_ = LTime(argu{:});
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
            obj.git = obj.git + 1;
            % ---
            ltime_ = fieldnames(obj.ltime);
            % ---
            for i = 1:length(ltime_)
                obj.ltime.(ltime_{i}).lit = obj.ltime.(ltime_{i}).lit + 1;
                if obj.ltime.(ltime_{i}).ltime_now > obj.gtime_now
                    obj.ltime.(ltime_{i}).lit = obj.ltime.(ltime_{i}).lit - 1;
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function init(obj)
            ltime_ = fieldnames(obj.ltime);
            % ---
            gtime_array_ = [];
            for i = 1:length(ltime_)
                gtime_array_ = [gtime_array_ obj.ltime.(ltime_{i}).ltime_array];
            end
            % ---
            gtime_array_ = sort(unique(gtime_array_));
            % ---
            obj.gtime_array = gtime_array_;
            % --- !!!
            obj.git = 0;
            % ---
            ltime_ = fieldnames(obj.ltime);
            % ---
            for i = 1:length(ltime_)
                obj.ltime.(ltime_{i}).lit = 0;
            end
            % ---
            obj.init_done = 1;
        end
    end
end