%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom2d < VolumeDom

    % --- Properties
    properties
        id_xline
        id_yline
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = VolumeDom2d(args)
            arguments
                % ---
                args.parent_mesh
                args.id_xline = []
                args.id_yline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            obj = obj@VolumeDom;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            elseif ~isempty(obj.gid_elem)
                obj.build_from_gid_elem
            elseif ~isempty(obj.id_xline) && ~isempty(obj.id_yline)
                obj.build_from_idmesh1d;
            end
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function build_from_idmesh1d(obj)
            id_xline_ = f_to_dcellargin(obj.id_xline);
            id_yline_ = f_to_dcellargin(obj.id_yline);
            [id_xline_, id_yline_] = f_pairing_dcellargin(id_xline_, id_yline_);
            % ---
            all_id_mesh1d = fieldnames(obj.parent_mesh.mesh1d_collection.data);
            id_all_elem   = 1:obj.parent_mesh.nb_elem;
            all_elem_code = obj.parent_mesh.elem_code;
            gid_elem_ = [];
            elem_code_ = [];
            for i = 1:length(id_xline_)
                for j = 1:length(id_xline_{i})
                    idx = id_xline_{i}{j};
                    valid_idx = f_validid(idx,all_id_mesh1d);
                    % ---
                    for m = 1:length(valid_idx)
                        codeidx = obj.parent_mesh.mesh1d_collection.data.(valid_idx{m}).elem_code;
                        for k = 1:length(id_yline_{i})
                            idy = id_yline_{i}{k};
                            valid_idy = f_validid(idy,all_id_mesh1d);
                            % ---
                            for l = 1:length(valid_idy)
                                codeidy = obj.parent_mesh.mesh1d_collection.data.(valid_idy{l}).elem_code;
                                % ---
                                given_elem_code = codeidx * codeidy;
                                gid_elem_ = [gid_elem_ ...
                                            id_all_elem(all_elem_code == given_elem_code)];
                                elem_code_ = [elem_code_ given_elem_code];
                            end
                        end
                    end
                end
            end
            % -------------------------------------------------------------
            obj.elem_code = unique(elem_code_);
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
    end

end



