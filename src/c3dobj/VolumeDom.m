%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom < Xhandle

    % --- Properties
    properties
        parent_mesh Mesh
        elem_code
        id_elem
        build_from
        condition
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = VolumeDom(args)
            arguments
                % ---
                args.parent_mesh
                args.elem_code = []
                args.id_elem = []
                args.build_from = []
                args.condition = []
            end
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function allmeshes = build_from_elem_code(obj)
            id_elem_ = [];
            for i = 1:length(obj.elem_code)
                id_elem_ = [id_elem_ find(obj.parent_mesh.elem_code == obj.elem_code(i))];
            end
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,id_elem_);
            elem_type = obj.parent_mesh.elem_type;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                idElem = ...
                    f_find_elem(node,elem,'elem_type',elem_type,'condition', obj.condition);
                id_elem_ = id_elem_(idElem);
            end
            % -------------------------------------------------------------
            elem = obj.parent_mesh.elem(:,id_elem_);
            % -------------------------------------------------------------
            allmeshes{1} = feval(class(obj.parent_mesh),'node',node,'elem',elem);
            allmeshes{1}.gid_elem = id_elem_;
        end
        % -----------------------------------------------------------------
        function allmeshes = build_from_id_elem(obj)
            id_elem_ = obj.id_elem;
            % -------------------------------------------------------------
            obj.elem_code = unique(obj.parent_mesh.elem_code(id_elem_));
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,id_elem_);
            elem_type = obj.parent_mesh.elem_type;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                idElem = ...
                    f_find_elem(node,elem,'elem_type',elem_type,'condition', obj.condition);
                id_elem_ = id_elem_(idElem);
            end
            % -------------------------------------------------------------
            elem = obj.parent_mesh.elem(:,id_elem_);
            % -------------------------------------------------------------
            allmeshes{1} = feval(class(obj.parent_mesh),'node',node,'elem',elem);
            allmeshes{1}.gid_elem = id_elem_;
        end
        % -----------------------------------------------------------------
    end

end



