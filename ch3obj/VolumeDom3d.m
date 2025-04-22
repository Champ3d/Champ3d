%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom3d < VolumeDom

    % --- Properties
    properties
        id_dom2d
        id_zline
    end

    % --- subfields to build
    properties
        
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','id_dom2d','id_zline','elem_code', ...
                        'gid_elem','condition'};
        end
    end
    % --- Constructors
    methods
        function obj = VolumeDom3d(args)
            arguments
                % ---
                args.parent_mesh = []
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition = []
            end
            % ---
            obj = obj@VolumeDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            VolumeDom3d.setup(obj);
            % ---
        end
    end
    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@VolumeDom(obj);
            % ---
            if ~isempty(obj.id_zline)
                obj.build_from_idmesh1d2d;
            end
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % reset super
            reset@VolumeDom(obj);
            % ---
            obj.setup_done = 0;
            VolumeDom3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            VolumeDom3d.setup(obj);
            % ---
            build@VolumeDom(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_defining_obj;
            % ---
            obj.build_done = 1;
            % ---
        end
    end

    % --- Methods
    methods (Access = private)
        % -----------------------------------------------------------------
        function build_from_idmesh1d2d(obj)
            id_dom2d_ = f_to_dcellargin(obj.id_dom2d);
            id_zline_ = f_to_dcellargin(obj.id_zline);
            [id_dom2d_, id_zline_] = f_pairing_dcellargin(id_dom2d_, id_zline_);
            % ---
            all_id_dom2d  = fieldnames(obj.parent_mesh.parent_mesh2d.dom);
            all_id_mesh1d = fieldnames(obj.parent_mesh.parent_mesh1d.dom);
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
                        % ---
                        dom2d = obj.parent_mesh.parent_mesh2d.dom.(valid_iddom2d{m});
                        dom2d.is_defining_obj_of(obj);
                        % ---
                        codedom2d = dom2d.elem_code;
                        % ---
                        for o = 1:length(codedom2d)
                            for k = 1:length(id_zline_{i})
                                idz = id_zline_{i}{k};
                                valid_idz = f_validid(idz,all_id_mesh1d);
                                % ---
                                for l = 1:length(valid_idz)
                                    % ---
                                    zline = obj.parent_mesh.parent_mesh1d.dom.(valid_idz{l});
                                    zline.is_defining_obj_of(obj);
                                    % ---
                                    codeidz = zline.elem_code;
                                    % ---
                                    given_elem_code = codedom2d(o) .* codeidz;
                                    gid_elem_ = [gid_elem_ ...
                                                id_all_elem(all_elem_code == given_elem_code)];
                                    % ---
                                    elem_code_ = [elem_code_ given_elem_code];
                                end
                            end
                        end
                    end
                end
            end
            % ---
            gid_elem_ = unique(gid_elem_);
            % -------------------------------------------------------------
            if ~isempty(obj.condition)
                % ---------------------------------------------------------
                node = obj.parent_mesh.node;
                elem = obj.parent_mesh.elem(:,gid_elem_);
                elem_type = obj.parent_mesh.elem_type;
                % ---
                idElem = ...
                    f_findelem(node,elem,'condition', obj.condition);
                gid_elem_ = gid_elem_(idElem);
            end
            % -------------------------------------------------------------
            obj.gid_elem  = unique(gid_elem_);
            obj.elem_code = unique(obj.parent_mesh.elem_code(gid_elem_));
            % -------------------------------------------------------------
        end
    end
end



