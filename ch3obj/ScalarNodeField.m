%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ScalarNodeField < MeshField
    properties
        parent_mesh
        dof
    end
    properties (Dependent)
        value
        node
    end
    % --- Contructor
    methods
        function obj = ScalarNodeField(args)
            arguments
                args.parent_mesh {mustBeA(args.parent_mesh,'Mesh')}
                args.dof {mustBeA(args.dof,'NodeDof')}
            end
            % ---
            obj = obj@MeshField;
            % ---
            if ~isfield(args,'parent_mesh') || ~isfield(args,'dof')
                error('#parent_mesh and #dof must be given !');
            end
            obj <= args;
        end
    end
    % --- Methods/public
    methods
        % -----------------------------------------------------------------
        function val = get.value(obj)
            val = obj.parent_mesh.field_wn('dof',obj.dof.value,'on','center');
        end
        % -----------------------------------------------------------------
        function val = get.node(obj)
            val = obj.parent_mesh.node;
        end
    end
end