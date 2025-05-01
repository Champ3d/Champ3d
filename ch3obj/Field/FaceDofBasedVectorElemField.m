%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FaceDofBasedVectorElemField < VectorElemField
    properties
        parent_model
        dof
    end
    % properties (Dependent)
    %     cvalue
    %     cnode
    %     ivalue
    %     inode
    %     gvalue
    %     gnode
    % end
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