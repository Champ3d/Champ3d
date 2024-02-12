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
                args.id_elem = []
                args.condition = []
            end
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.elem_code)
                obj.build_from = 'elem_code';
            elseif ~isempty(obj.id_elem)
                obj.build_from = 'id_elem';
            else
                obj.build_from = 'id_mesh1d2d';
            end
        end
    end

    % --- Methods
    methods
        function allmeshes = submesh(obj)
            switch obj.build_from
                case 'id_mesh1d2d'
                    allmeshes = obj.build_from_idmesh1d2d;
                case 'elem_code'
                    allmeshes = obj.build_from_elem_code;
                case 'id_elem'
                    allmeshes = obj.build_from_id_elem;
            end
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function allmeshes = build_from_idmesh1d2d(obj)
            id_dom2d_ = f_to_dcellargin(obj.id_dom2d);
            id_zline_ = f_to_dcellargin(obj.id_zline);
            [id_dom2d_, id_zline_] = f_pairing_dcellargin(id_dom2d_, id_zline_);
            % ---
            all_id_dom2d  = fieldnames(obj.dom2d_collection.data);
            all_id_mesh1d = fieldnames(obj.parent_mesh.mesh1d_collection.data);
            all_elem_code = obj.parent_mesh.elem_code;
            id_all_elem   = 1:obj.parent_mesh.nb_elem;
            % ---
            id_elem_ = [];
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
                                    id_elem_ = [id_elem_ ...
                                                id_all_elem(all_elem_code == given_elem_code)];
                                end
                            end
                        end
                    end
                end
            end
            % ---
            elem_code_ = unique(elem_code_);
            id_elem_ = unique(id_elem_);
            % -------------------------------------------------------------
            obj.elem_code = elem_code_;
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
            obj.id_elem = id_elem_;
            % -------------------------------------------------------------
            allmeshes{1} = feval(class(obj.parent_mesh),'node',node,'elem',elem);
            allmeshes{1}.gid_elem = id_elem_;
        end
    end

end



