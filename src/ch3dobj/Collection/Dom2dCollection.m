%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Dom2dCollection < Xhandle

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
        function obj = Dom2dCollection(args)
            arguments
                args.info char = 'no_info'
                args.data = []
                args.parent_mesh Mesh
            end
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        function obj = add_volume_dom2d(obj,args)
            arguments
                obj
                % ---
                args.id char
                args.id_xline = []
                args.id_yline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            argu = f_to_namedarg(args,'with_out','id');
            vdom = VolumeDom2d(argu{:},'parent_mesh',obj.parent_mesh);
            % ---
            obj.data.(args.id) = vdom;
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end

end



