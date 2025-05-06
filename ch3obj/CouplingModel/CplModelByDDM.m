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

classdef CplModelByDDM < CplModel

    properties
        scheme
    end

    % --- Constructor
    methods
        function obj = CplModelByDDM()
            obj = obj@CplModel;
        end
    end

    % --- Methods
    methods
        % ---
        function solve(obj)
            if f_strcmpi(obj.scheme,'s-->l')
                obj.source.solve;
                for i = 1:length(obj.loads)
                    obj.transfer(obj.source,obj.loads{i});
                end
            elseif f_strcmpi(obj.scheme,'s<-->l')
                %while not(obj.convergent)
                    obj.source.solve;
                    for i = 1:length(obj.loads)
                        obj.transfer(obj.source,obj.loads{i});
                        obj.loads{i}.solve;
                        obj.transfer(obj.loads{i},obj.source);
                    end
                %end
            end
        end
    end
    % --- Methods
    methods
        function build_timesystem(obj)
            % ---
            time_system_ = TimeSystem;
            time_system_.ltime.source = obj.source.ltime;
            % ---
            for i = 1:length(obj.loads)
                id_ = ['load_' num2str(i)];
                time_system_.ltime.(id_) = obj.loads{i}.ltime;
            end
            % ---
            obj.time_system = time_system_;
        end
        % ---
        function solve_all(obj)
            obj.build_timesystem;
            obj.time_system.init;
            % ---
            obj.time_system.t_now
            while obj.time_system.t_now < obj.time_system.t_end
                obj.solve;
                obj.time_system.increment;
                obj.time_system.t_now
            end
        end
    end
    % --- Methods
    methods (Abstract)
        transfer(source,load)
    end
end