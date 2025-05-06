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

classdef CplModelByParameter < CplModel

    properties
        model = {}
    end

    % --- Constructor
    methods
        function obj = CplModelByParameter(model_list)
            arguments
                model_list = []
            end
            % ---
            obj = obj@CplModel;
            % ---
            if ~isempty(model_list)
                obj.model = f_to_scellargin(model_list);
            end
        end
    end

    % --- Methods
    methods
        function add_model(obj,model)
            arguments
                obj
                model = []
            end
            % ---
            if ~isempty(model)
                obj.model{end+1} = model;
                obj.model = f_to_scellargin(obj.model);
            end
        end
        % ---
        function solve(obj)
            for i = 1:length(obj.model)
                obj.model{i}.solve;
            end
        end
    end
end