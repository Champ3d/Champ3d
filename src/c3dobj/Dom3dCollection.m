%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Dom3dCollection < Xhandle

    % --- Properties
    properties
        info = []
        data = []
        parent_mesh Mesh
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = Dom3dCollection(args)
            arguments
                args.info char = 'no_info'
                args.data = []
                args.parent_mesh Mesh
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function obj = add_volume_dom3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                args.dom2d_collection Dom2dCollection
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            argu = f_to_namedarg(args,'with_out','id');
            vdom = VolumeDom3d(argu{:},'parent_mesh',obj.parent_mesh);
            % ---
            obj.data.(args.id) = vdom;
        end
        % -----------------------------------------------------------------
        function obj = add_surface_dom3d(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.parent_mesh
                args.gid_face = []
                args.condition = []
                % ---
                args.defined_on char = []
                args.dom3d_collection Dom3dCollection
                args.id_dom3d
            end
            % ---
            argu = f_to_namedarg(args,'with_out','id');
            sdom = SurfaceDom3d(argu{:},'parent_mesh',obj.parent_mesh);
            % ---
            obj.data.(args.id) = sdom;
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end

end



