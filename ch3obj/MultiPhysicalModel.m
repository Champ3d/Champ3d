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
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef MultiPhysicalModel < Xhandle

    % --- Properties
    properties
        model
        time_system
    end

    % --- Constructors
    methods
        function obj = MultiPhysicalModel()
            obj = obj@Xhandle;
            % ---
        end
    end

    % --- Methods
    methods
        function add_model(obj,args)
            arguments
                obj
                args.id
                args.model
            end
            % ---
            if ~isempty(args)
                if ~isempty(args.id) && ~isempty(args.model)
                    obj.model.(args.id) = args.model;
                end
            end
        end
        % ---
    end

    % --- Methods
    methods
        function build_timesystem(obj)
            % ---
            time_system_ = TimeSystem;
            model_ = fieldnames(obj.model);
            % ---
            for i = 1:length(model_)
                id_ = model_{i};
                ltime_ = obj.model.(model_{i}).ltime;
                time_system_.ltime.(id_) = ltime_;
            end
            % ---
            obj.time_system = time_system_;
        end
        % -----------------------------------------------------------------
        function solve(obj)
            obj.build_timesystem;
            obj.time_system.init;
            % ---
            idmodel = fieldnames(obj.model);
            % ---
            while obj.time_system.gtime_now <= obj.time_system.t_end
                for i = 1:length(idmodel)
                    obj.model.(idmodel{i}).solve;
                end
                obj.time_system.increment;
            end
        end
    end
end