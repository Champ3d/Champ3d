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

classdef NodeDofBasedScalarNodeField < ScalarNodeField
    properties
        parent_model
        dof
        % ---
        reference_potential = 0
    end
    % --- Contructor
    methods
        function obj = NodeDofBasedScalarNodeField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'NodeDof')}
                args.reference_potential = 0
            end
            % ---
            obj = obj@ScalarNodeField;
            % ---
            if nargin > 1
                if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                    error('#parent_model and #dof must be given !');
                end
            end
            % ---
            obj <= args;
        end
    end
    % --- Get
    methods
        % -----------------------------------------------------------------
        function val = cvalue(obj,id_node)
            % ---
            if nargin <= 1
                id_node = 1:obj.parent_model.parent_mesh.nb_node;
            end
            % ---
            if isempty(id_node)
                val = [];
                return
            end
            % ---
            val = obj.dof.value(id_node) + obj.reference_potential;
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_node)
            % ---
            if nargin <= 1
                id_node = 1:obj.parent_model.parent_mesh.nb_node;
            end
            % ---
            if isempty(id_node)
                val = [];
                return
            end
            % ---
            val{1} = obj.dof.value(id_node) + obj.reference_potential;
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_node)
            % ---
            if nargin <= 1
                id_node = 1:obj.parent_model.parent_mesh.nb_node;
            end
            % ---
            if isempty(id_node)
                val = [];
                return
            end
            % ---
            val{1} = obj.dof.value(id_node) + obj.reference_potential;
        end
        % -----------------------------------------------------------------
    end
end