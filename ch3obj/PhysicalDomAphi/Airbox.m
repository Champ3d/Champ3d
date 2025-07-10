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

classdef Airbox < PhysicalDom
    % ---
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d'};
        end
    end
    % --- Contructor
    methods
        function obj = Airbox(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Airbox.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.gid_inner_edge = [];
            % ---
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            Airbox.setup(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            it = obj.parent_model.ltime.it;
            % ---
            dom = obj.dom;
            obj.dom.get_gid;
            obj.matrix.gid_elem = dom.gid.gid_elem;
            obj.matrix.gid_inner_edge = dom.gid.gid_inner_edge;
            obj.matrix.gid_edge = dom.gid.gid_edge;
            % ---
            obj.build_done = 1;
        end
    end
    % --- assembly
    methods
        function assembly(obj)
            obj.build;
            % ---
            obj.parent_model.matrix.id_elem_airbox = ...
                unique([obj.parent_model.matrix.id_elem_airbox, obj.matrix.gid_elem]);
            switch obj.parent_model.airbox_bcon
                case 'nullfield'
                    obj.parent_model.matrix.id_inner_edge_airbox = ...
                    unique([obj.parent_model.matrix.id_inner_edge_airbox, obj.matrix.gid_inner_edge]);
                case 'free'
                    obj.parent_model.matrix.id_inner_edge_airbox = ...
                    unique([obj.parent_model.matrix.id_inner_edge_airbox, obj.matrix.gid_edge]);
            end
            % ---
            obj.parent_model.matrix.id_edge_airbox = ...
                unique([obj.parent_model.matrix.id_edge_airbox, obj.matrix.gid_edge]);
        end
    end
end