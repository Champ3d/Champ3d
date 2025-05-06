%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef EdgeDof < Xhandle
    properties
        parent_model
        % ---
        value
    end
    % --- Contructor
    methods
        function obj = EdgeDof(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.value = []
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model')
                error('#parent_model must be given');
            end
            % ---
            obj.parent_model = args.parent_model;
            obj.value = args.value;
            % ---
        end
    end
    % --- set/check
    methods
        % -----------------------------------------------------------------
        function set.value(obj,value)
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            if isempty(value)
                obj.value = zeros(nb_edge,1);
            elseif numel(value) == 1
                obj.value = value .* ones(nb_edge,1);
            else
                if numel(value) ~= nb_edge
                    error('#value must correspond to mesh edge, check size !');
                else
                    obj.value = f_tocolv(value);
                end
            end
        end
    end
end