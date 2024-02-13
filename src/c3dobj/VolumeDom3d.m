%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom3d < VolumeDom

    % --- Properties
    properties
        dom2d_collection
        id_dom2d
        id_zline
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = VolumeDom3d(args)
            arguments
                % ---
                args.parent_mesh
                args.dom2d_collection Dom2dCollection
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition = []
            end
            % ---
            obj = obj@VolumeDom;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.elem_code)
                obj.build_from_elem_code;
            elseif ~isempty(obj.gid_elem)
                obj.build_from_gid_elem;
            elseif ~isempty(obj.dom2d_collection) && ~isempty(obj.id_dom2d) ...
                    && ~isempty(obj.id_zline)
                obj.build_from_idmesh1d2d;
            end
            % ---
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function build_from_idmesh1d2d(obj)
            id_dom2d_ = f_to_dcellargin(obj.id_dom2d);
            id_zline_ = f_to_dcellargin(obj.id_zline);
            [id_dom2d_, id_zline_] = f_pairing_dcellargin(id_dom2d_, id_zline_);
            % ---
            all_id_dom2d  = fieldnames(obj.dom2d_collection.data);
            all_id_mesh1d = fieldnames(obj.parent_mesh.mesh1d_collection.data);
            all_elem_code = obj.parent_mesh.elem_code;
            id_all_elem   = 1:obj.parent_mesh.nb_elem;
            % ---
            gid_elem_ = [];
            elem_code_ = [];
            % ---
            for i = 1:length(id_dom2d_)
                for j = 1:length(id_dom2d_{i})
                    iddom2d = id_dom2d_{i}{j};
                    valid_iddom2d = f_validid(iddom2d,all_id_dom2d);
                    % ---
                    for m = 1:length(valid_iddom2d)
                        codedom2d = obj.dom2d_collection.data.(valid_iddom2d{m}).elem_code;
                        for o = 1:length(codedom2d)
                            for k = 1:length(id_zline_{i})
                                idz = id_zline_{i}{k};
                                valid_idz = f_validid(idz,all_id_mesh1d);
                                % ---
                                for l = 1:length(valid_idz)
                                    codeidz = obj.parent_mesh.mesh1d_collection.data.(valid_idz{l}).elem_code;
                                    % ---
                                    elem_code_ = [elem_code_ codedom2d(o) .* codeidz];
                                    % ---
                                    given_elem_code = codedom2d(o) .* codeidz;
                                    gid_elem_ = [gid_elem_ ...
                                                id_all_elem(all_elem_code == given_elem_code)];
                                end
                            end
                        end
                    end
                end
            end
            % ---
            elem_code_ = unique(elem_code_);
            gid_elem_ = unique(gid_elem_);
            % -------------------------------------------------------------
            obj.elem_code = elem_code_;
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



