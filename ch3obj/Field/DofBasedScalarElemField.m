%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef DofBasedScalarElemField < DofBaseMeshField
    properties
        reference_potential = 0
    end
    properties (Dependent)
        value
        node
    end
    % --- Contructor
    methods
        function obj = DofBasedScalarElemField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'NodeDof')}
                args.reference_potential = 0
            end
            % ---
            obj = obj@DofBaseMeshField;
            % ---
            if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                error('#parent_model and #dof must be given !');
            end
            obj <= args;
        end
    end
    % --- Methods/public
    methods
        % -----------------------------------------------------------------
        function val = get.value(obj)
            val = obj.parent_model.parent_mesh.field_wn('dof',obj.dof.value,'on','center') ...
                  + obj.reference_potential;
        end
        % -----------------------------------------------------------------
        function val = get.node(obj)
            val = obj.parent_model.parent_mesh.celem;
        end
    end
end