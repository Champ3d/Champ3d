%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef CutVolumeDom3d < VolumeDom

    % --- Properties
    properties
        id_dom3d
        cut_equation
        gid_side_node_1
        gid_side_node_2
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = CutVolumeDom3d(args)
            arguments
                % ---
                args.parent_mesh = []
                args.id_dom3d = []
                args.cut_equation = []
            end
            % ---
            obj = obj@VolumeDom;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.id_dom3d) && ~isempty(obj.cut_equation)
                obj.build;
            end
            % ---
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function build(obj)
            iddom3 = f_to_scellargin(obj.id_dom3d);
            iddom3 = iddom3{1};
            cutequ = f_to_scellargin(obj.cut_equation);
            cutequ = cutequ{1};
            % ---
            all_id_dom2d  = fieldnames(obj.parent_mesh.parent_mesh2d.dom);
            all_id_mesh1d = fieldnames(obj.parent_mesh.parent_mesh1d.dom);
            all_elem_code = obj.parent_mesh.elem_code;
            id_all_elem   = 1:obj.parent_mesh.nb_elem;
            % ---
            gid_elem_ = [];
            elem_code_ = [];
            % -------------------------------------------------------------
            obj.gid_elem  = unique(gid_elem_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gid_elem_));
            % -------------------------------------------------------------
        end
    end

end



