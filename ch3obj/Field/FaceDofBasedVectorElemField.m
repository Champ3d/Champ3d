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

classdef FaceDofBasedVectorElemField < VectorElemField
    properties
        parent_model
        dof
    end
    % --- Contructor
    methods
        function obj = FaceDofBasedVectorElemField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'FaceDof')}
            end
            % ---
            obj = obj@VectorElemField;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                    error('#parent_model and #dof must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cvalue(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            val = obj.parent_model.parent_mesh.field_wf('dof',obj.dof.value,...
                  'on','center','id_elem',id_elem);
            val = val(:,id_elem);
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            val = obj.parent_model.parent_mesh.field_wf('dof',obj.dof.value,...
                  'on','interpolation_points','id_elem',id_elem);
            % ---
            if length(id_elem) < obj.parent_model.parent_mesh.nb_elem
                for i = 1:length(val)
                    val{i} = val{i}(:,id_elem);
                end
            end
            % ---

        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            val = obj.parent_model.parent_mesh.field_wf('dof',obj.dof.value,...
                  'on','gauss_points','id_elem',id_elem);
            % ---
            if length(id_elem) < obj.parent_model.parent_mesh.nb_elem
                for i = 1:length(val)
                    val{i} = val{i}(:,id_elem);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
end