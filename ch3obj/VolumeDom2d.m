%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VolumeDom2d < VolumeDom

    % --- Properties
    properties
        id_xline
        id_yline
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
            argslist = {'parent_mesh','id_xline','id_yline','elem_code', ...
                        'gid_elem','condition'};
        end
    end
    % --- Constructors
    methods
        function obj = VolumeDom2d(args)
            arguments
                % ---
                args.parent_mesh = []
                args.id_xline = []
                args.id_yline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
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
            VolumeDom2d.setup(obj);
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
            if ~isempty(obj.id_xline) && ~isempty(obj.id_yline)
                obj.build_from_idmesh1d;
            end
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % reset super class
            reset@VolumeDom(obj);
            % ---
            obj.setup_done = 0;
            VolumeDom2d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
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
            all_id_mesh1d = fieldnames(obj.parent_mesh.parent_mesh.dom);
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
                        % ---
                        xlineobj = obj.parent_mesh.parent_mesh.dom.(valid_idx{m});
                        % ---
                        % xlineobj.is_defining_obj_of(obj);
                        % ---
                        codeidx = xlineobj.elem_code;
                        % ---
                        for k = 1:length(id_yline_{i})
                            idy = id_yline_{i}{k};
                            valid_idy = f_validid(idy,all_id_mesh1d);
                            % ---
                            for l = 1:length(valid_idy)
                                % ---
                                ylineobj = obj.parent_mesh.parent_mesh.dom.(valid_idy{l});
                                % ---
                                % ylineobj.is_defining_obj_of(obj);
                                % ---
                                codeidy = ylineobj.elem_code;
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



