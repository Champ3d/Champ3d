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

classdef OpenCoil < Coil
    % --- entry
    properties
        etrode_equation
    end
    % --- computed
    properties
        gid_node_petrode
        gid_node_netrode
    end
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','etrode_equation'};
        end
    end
    % --- Contructor
    methods
        function obj = OpenCoil(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
            end
            % ---
            obj@Coil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            OpenCoil.setup(obj);
            % ---
            % must reset build+assembly
            obj.build_done = 0;
            obj.assembly_done = 0;
        end
    end
    
    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@Coil(obj);
            % ---
            obj.etrode_equation = f_to_scellargin(obj.etrode_equation);
            % ---
            obj.get_electrode;
            % ---
            obj.setup_done = 1;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % ---
            % must reset setup+build+assembly
            obj.setup_done = 0;
            obj.build_done = 0;
            obj.assembly_done = 0;
            % ---
            % must call super reset
            % ,,, with obj as argument
            reset@Coil(obj);
        end
    end
    methods
        function build(obj)
            % ---
            OpenCoil.setup(obj);
            % ---
            build@Coil(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end
    methods
        function assembly(obj)
            % ---
            obj.build;
            assembly@Coil(obj);
            % ---
            if obj.assembly_done
                return
            end
            % ---
            obj.assembly_done = 1;
            % ---
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            % ---
            parent_mesh = obj.parent_model.parent_mesh;
            etrode_eq = obj.etrode_equation;
            id_dom3d = f_to_scellargin(obj.id_dom3d);
            id_dom3d = id_dom3d{1};
            % ---
            gid_elem = parent_mesh.dom.(id_dom3d).gid_elem;
            boface = f_boundface(parent_mesh.elem(:,gid_elem),...
               parent_mesh.node,'elem_type',parent_mesh.elem_type);
            % ---
            gid_node = f_uniquenode(boface);
            % ---
            bonode = parent_mesh.node(:,gid_node);
            % ---
            petrode = [];
            netrode = [];
            for i = 1:length(etrode_eq)
                condi = etrode_eq{i};
                lid_node = f_findnode(bonode,'condition',condi);
                if i == 1
                    petrode = lid_node;
                    % ---
                    if isempty(petrode)
                        warning(['Electrode not found from eq ' etrode_eq{i}]);
                    end
                else
                    netrode = [netrode lid_node];
                    % ---
                    if isempty(netrode)
                        warning(['Electrode not found from eq ' etrode_eq{i}]);
                    end
                end
            end
            % -------------------------------------------------------------
            obj.gid_node_petrode = unique(gid_node(petrode));
            obj.gid_node_netrode = unique(gid_node(netrode));
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
            penode = obj.parent_model.parent_mesh.node(:,obj.gid_node_petrode);
            nenode = obj.parent_model.parent_mesh.node(:,obj.gid_node_netrode);
            if size(penode,1) == 2
                plot(penode(1,:),penode(2,:),'ro'); hold on
                plot(nenode(1,:),nenode(2,:),'bo'); hold on
            elseif size(penode,1) == 3
                plot3(penode(1,:),penode(2,:),penode(3,:),'ro'); hold on
                plot3(nenode(1,:),nenode(2,:),nenode(3,:),'bo'); hold on
            end
        end
        % -----------------------------------------------------------------
    end
end