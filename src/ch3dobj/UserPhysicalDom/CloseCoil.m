%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef CloseCoil < Coil
    % --- entry
    properties
        etrode_equation
    end
    % --- computed
    properties
        electrode_dom
        shape_dom
    end

    % --- Contructor
    methods
        function obj = CloseCoil(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.connexion
                args.source_type
                args.coil_type
                args.coil_mode
                args.i_coil
                args.v_coil
                args.j_coil
                args.etrode_equation
            end
            % ---
            obj = obj@Coil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.to_be_rebuild = 1;
            % ---
            obj.build;
        end
    end
    
    % --- build
    methods
        function build(obj)
            if obj.to_be_rebuild
                % ---
                build@Coil(obj);
                % ---
                obj.etrode_equation = f_to_scellargin(obj.etrode_equation);
                obj.etrode_equation = obj.etrode_equation{1};
                % ---
                obj.get_electrode;
            end
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            if ~isempty(obj.parent_model)
                if ~isempty(obj.parent_model.parent_mesh)
                    % ---
                    args4cv3.parent_mesh = obj.parent_model.parent_mesh;
                    args4cv3.id_dom3d = obj.id_dom3d;
                    args4cv3.cut_equation = obj.etrode_equation;
                    argu = f_to_namedarg(args4cv3,'with_only',...
                                {'parent_mesh','id_dom3d','cut_equation'});
                    % ---
                    obj.electrode_dom = CutVolumeDom3d(argu{:});
                    % ---
                    coilshape = obj.dom - obj.electrode_dom;
                    % ---
                    obj.shape_dom = eval(class(obj.electrode_dom));
                    obj.shape_dom <= coilshape;
                    % ---
                    obj.shape_dom.gid_side_node_1 = obj.electrode_dom.gid_side_node_2;
                    obj.shape_dom.gid_side_node_2 = obj.electrode_dom.gid_side_node_1;
                end
            end
        end
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'none'
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            plot@Coil(obj,argu{:}); hold on
            % ---
            etrode = obj.electrode_dom;
            etrode.plot('face_color',f_color(100));
        end
        % -----------------------------------------------------------------
    end
end