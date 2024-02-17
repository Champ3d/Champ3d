%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh2d < Mesh

    % --- Constructors
    methods
        function obj = Mesh2d()
            obj = obj@Mesh;
        end
    end

    % --- Methods
    methods
        % ---
        function add_vdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                         {'parent_mesh','id_xline','id_yline','elem_code',...
                          'gid_elem','condition'});
            vdom = VolumeDom2d(argu{:});
            obj.dom.(args.id) = vdom;
            % ---
        end
        % --- XTODO
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d = []
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                         {'mesh1d','parent_mesh','id_xline','id_yline','elem_code',...
                          'gid_elem','condition'});
            vdom = VolumeDom2d(argu{:});
            obj.dom.(args.id) = vdom;
            % ---
        end
    end
end




