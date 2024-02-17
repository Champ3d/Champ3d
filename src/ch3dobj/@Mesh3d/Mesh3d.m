%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh3d < Mesh

    % --- Constructors
    methods
        function obj = Mesh3d()
            obj = obj@Mesh;
            obj.meshds.sign_edge_in_elem = 0;
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
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                {'parent_mesh','id_dom2d','id_zline',...
                 'elem_code','gid_elem','condition'});
            vdom = VolumeDom3d(argu{:});
            obj.dom.(args.id) = vdom;
            % ---
        end
        % -----------------------------------------------------------------
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.defined_on char = []
                args.id_dom3d = []
                % ---
                args.elem_code = []
                args.gid_face = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                {'parent_mesh','id_dom3d','defined_on',...
                 'gid_face','condition'});
            sdom = SurfaceDom3d(argu{:});
            obj.dom.(args.id) = sdom;
            % ---
        end
    end
end




