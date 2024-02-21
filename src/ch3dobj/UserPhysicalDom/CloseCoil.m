%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef CloseCoil < PhysicalDom
    properties
        id_electrode_dom3d
        electrode_dom
        shape_dom
    end

    % --- Contructor
    methods
        function obj = CloseCoil(args)
            obj = obj@PhysicalDom(args);
            obj <= args;
            obj.get_electrode;  
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            if ~isempty(obj.parent_model)
                if ~isempty(obj.parent_model.parent_mesh)
                    % ---
                    if ~isempty(obj.id_electrode_dom3d)
                        id_dom_ = f_to_scellargin(obj.id_electrode_dom3d);
                    end
                    % ---
                    obj.electrode_dom = obj.parent_model.parent_mesh.dom.(id_dom_{1});
                    for i = 2:length(id_dom_)
                        obj.electrode_dom = obj.electrode_dom + obj.parent_model.parent_mesh.dom.(id_dom_{i});
                    end
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
            plot@PhysicalDom(obj,argu{:}); hold on
            % ---
            etrode = obj.electrode_dom;
            etrode.plot('face_color',f_color(100));
        end
        % -----------------------------------------------------------------
    end
end