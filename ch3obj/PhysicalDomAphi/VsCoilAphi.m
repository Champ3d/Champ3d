%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VsCoilAphi < Xhandle

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    
    % --- Contructor
    methods
        function obj = VsCoilAphi()
            obj@Xhandle;
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            dom = obj.dom;
            obj.matrix.v_coil = obj.v_coil.get('in_dom',dom);
            % ---
            obj.build_done = 1;
            obj.assembly_done = 0;
        end
    end

    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            % ---
            if obj.assembly_done
                return
            end
            % ---
            obj.parent_model.matrix.id_node_netrode = ...
                [obj.parent_model.matrix.id_node_netrode obj.gid_node_netrode];
            obj.parent_model.matrix.id_node_petrode = ...
                [obj.parent_model.matrix.id_node_petrode obj.gid_node_petrode];
            % ---
            obj.assembly_done = 1;
        end
    end

    % --- reset
    methods
        function reset(obj)
            if isprop(obj,'setup_done')
                obj.setup_done = 0;
            end
            if isprop(obj,'build_done')
                obj.build_done = 0;
            end
            if isprop(obj,'assembly_done')
                obj.assembly_done = 0;
            end
        end
    end
end