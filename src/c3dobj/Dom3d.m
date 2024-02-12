%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Dom3d < Dom

    % --- Properties
    properties
        dom2d
        zline
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Hidden Properties
    properties (Hidden = true)
        dom2d__
        zline__
    end

    % --- Constructors
    methods
        function obj = Dom3d(args)
            arguments
                args.parent_mesh
                args.id char = 'dom2d'
                args.dom2d = []
                args.zline = []
                args.id_code = []
            end
            % ---
            obj.parent_mesh = args.parent_mesh;
            obj.id = args.id;
            obj.dom2d = args.dom2d;
            obj.zline = args.zline;
            obj.id_code = args.id_code;
            % ---
            obj.dom2d__ = f_to_scellargin(obj.dom2d);
            obj.zline__ = f_to_scellargin(obj.zline);
            [obj.dom2d__, obj.zline__] = f_pairing_scellargin(obj.dom2d__, obj.zline__);
            % ---
            if isempty(obj.id_code)
                obj.defined_with = 'dom2d_and_zline';
            else
                obj.defined_with = 'id_code';
            end
        end
    end

    % --- Methods
    methods
        function view(obj)
            
        end
        % -----------------------------------------------------------------
        function obj = local_mesh(obj)
            %mesh_type = class(obj);
            obj.local_mesh = 1;
        end
        % -----------------------------------------------------------------
        function msh = extracted_mesh(obj)
            % ---
            gid_elem = 1:obj.parent_mesh.nb_elem;
            id_elem  = [];
            % ---
            if f_strcmpi(obj.defined_with,'dom2d_and_zline')
                for i__ = 1:length(obj.dom2d__)
                    do__ = obj.dom2d__{i__};
                    zl__ = obj.zline__{i__};
                    for i = 1:length(do__)
                        do = do__(i);
                        for j = 1:length(zl__)
                            zl = zl__(j);
                            id_code_ = do.id_code * zl.id_code;
                            id_elem = [id_elem gid_elem(obj.parent_mesh.id_code == id_code_)];
                        end
                    end
                end
            elseif f_strcmpi(obj.defined_with,'id_code')
                for i = 1:length(obj.id_code)
                    id_elem = [id_elem gid_elem(obj.parent_mesh.id_code == obj.id_code(i))];
                end
            end
            % ---
            node = obj.parent_mesh.node;
            elem = obj.parent_mesh.elem(:,id_elem);
            msh  = feval(class(obj.parent_mesh),'node',node,'elem',elem);
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end

end



