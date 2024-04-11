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
            obj@Mesh;
            % ---
            obj.gcoor.cartesian.o = [0 0 0];
            % ---
            obj.gcoor.cylindrical.o = [0 0 0];
            obj.gcoor.cylindrical.otheta = [1 0 0]; % w/ counterclockwise convention
            % ---
            obj.move.linear.vector_step = [0 0 0];
            % ---
            obj.move.rotational.angle_step = 0;       % deg, counterclockwise
            obj.move.rotational.origin     = [0 0 0]; % rot around o-->axis
            obj.move.rotational.axis       = [0 0 1]; % rot around o-->axis
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
                % ---
                args.id_dom3d = [];
                args.cut_equation = [];
            end
            % ---
            args.parent_mesh = obj;
            % ---
            if isempty(args.id_dom3d) && isempty(args.cut_equation)
                argu = f_to_namedarg(args,'with_only',...
                    {'parent_mesh','id_dom2d','id_zline',...
                     'elem_code','gid_elem','condition'});
                vdom = VolumeDom3d(argu{:});
            else
                argu = f_to_namedarg(args,'with_only',...
                    {'parent_mesh','id_dom3d','cut_equation'});
                vdom = CutVolumeDom3d(argu{:});
            end
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




