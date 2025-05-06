%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VsCoilAphi < Xhandle

    % --- computed
    properties (Access = private)
        build_done = 0
        assembly_done = 0
    end
    
    % --- Contructor
    methods
        function obj = VsCoilAphi()
            obj@Xhandle;
        end
    end

    % --- setup
    methods
        function setup(obj)
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
            obj.matrix.v_coil = obj.v_coil.getvalue('in_dom',dom);
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