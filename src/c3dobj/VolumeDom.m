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
        parent_mesh
        elem_code
        gid_elem
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
                args.parent_mesh = []
                args.elem_code = []
                args.gid_elem = []
                args.condition = []
            end
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.gid_elem)
                obj.build_from_gid_elem;
            elseif ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            end
        end
    end

    % --- Methods
    methods
        function allmeshes = submesh(obj)
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,obj.gid_elem);
            % -------------------------------------------------------------
            allmeshes{1} = feval(class(obj.parent_mesh),'node',node,'elem',elem);
            allmeshes{1}.gid_elem = obj.gid_elem;
        end
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function build_from_elem_code(obj)
            gid_elem_ = [];
            for i = 1:length(obj.elem_code)
                gid_elem_ = [gid_elem_ f_torowv(find(obj.parent_mesh.elem_code == obj.elem_code(i)))];
            end
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,gid_elem_);
            elem_type = obj.parent_mesh.elem_type;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                idElem = ...
                    f_find_elem(node,elem,'elem_type',elem_type,'condition', obj.condition);
                gid_elem_ = gid_elem_(idElem);
            end
            % -------------------------------------------------------------
            obj.gid_elem = gid_elem_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function build_from_gid_elem(obj)
            gid_elem_ = obj.gid_elem;
            % -------------------------------------------------------------
            obj.elem_code = unique(obj.parent_mesh.elem_code(gid_elem_));
            % -------------------------------------------------------------
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,gid_elem_);
            elem_type = obj.parent_mesh.elem_type;
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                idElem = ...
                    f_find_elem(node,elem,'elem_type',elem_type,'condition', obj.condition);
                gid_elem_ = gid_elem_(idElem);
            end
            % -------------------------------------------------------------
            obj.gid_elem = gid_elem_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function objy = plus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = [f_torowv(obj.gid_elem) f_torowv(objx.gid_elem)];
            objy.build_from_gid_elem;
        end
        function objy = minus(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = setdiff(f_torowv(obj.gid_elem),f_torowv(objx.gid_elem));
            objy.build_from_gid_elem;
        end
        function objy = mpower(obj,objx)
            objy = feval(class(obj),'parent_mesh',obj.parent_mesh);
            objy.gid_elem = intersect(f_torowv(obj.gid_elem),f_torowv(objx.gid_elem));
            objy.build_from_gid_elem;
        end
    end

end
