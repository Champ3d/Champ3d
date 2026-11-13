%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2026
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
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef BiotSavartCoil < Coil
    properties
        Is
        turn = {}
        coil_mode = 'tx'
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'Is','turn','coil_mode'};
        end
    end
    % --- Constructors
    methods
        function obj = BiotSavartCoil(args)
            arguments
                args.parent_model
                args.Is = 0
                args.turn = {}
                args.coil_mode = 'tx'
            end
            % ---
            obj@Coil;
            % ---
            obj <= args;
            % ---
            BiotSavartCoil.setup(obj);
        end
    end
    % --- setup
    methods (Static)
        function setup(obj)
            % --- call utility methods
            obj.set_parameter;
            % --- Initialization
            obj.matrix.Is_array = [];
            obj.matrix.a_Is = [];
            % ---
            for i = 1:length(obj.turn)
                obj.turn{i}.setup;
            end
            % ---
            obj.build_done = 0;
        end
    end
    methods (Access = public)
        function reset(obj)
            FilamentCoil.setup(obj);
        end
    end
    % ---
    methods
        function add_turn(obj,turn_obj)
            obj.turn{end+1} = turn_obj;
        end
        % ---
        function rotate(obj,angle)
            for i = 1:length(obj.turn)
                obj.turn{i}.rotate(angle);
            end
            % ---
            obj.setup;
            % ---
        end
        % ---
        function translate(obj,distance)
            for i = 1:length(obj.turn)
                obj.turn{i}.translate(distance);
            end
            % ---
            obj.setup;
            % ---
        end
        % ---
        function plot(obj,args)
            arguments
                obj
                args.color = 'r'
            end
            % ---
            for i = 1:length(obj.turn)
                obj.turn{i}.plot("color",args.color);
            end
            % ---
            axis equal; xlabel("x (m)"); ylabel("y (m)"); zlabel("z (m)"); 
        end
    end
    % ---
    methods
        % -----------------------------------------------------------------------------
        function L = getL(obj)
            
        end
        % -----------------------------------------------------------------------------
        function fl = getflux(obj)
            
        end
        % -----------------------------------------------------------------------------
        function A = getanode(obj,args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
            end
            % ---
            if ~isfield(args,"node")
                A = [];
                return
            end
            % ---
            A = zeros(size(args.node));
            for i = 1:length(obj.turn)
                tx = obj.turn{i};
                tx.setup;
                A = A + tx.getanode("node",args.node,"I",obj.Is.getvalue());
            end
        end
        % -----------------------------------------------------------------------------
        function B = getbnode(obj,args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
            end
            % ---
            if ~isfield(args,"node")
                B = [];
                return
            end
            % ---
            B = zeros(size(args.node));
            for i = 1:length(obj.turn)
                tx = obj.turn{i};
                tx.setup;
                B = B + tx.getbnode("node",args.node,"I",obj.Is.getvalue());
            end
        end
    end
    % --- build
    methods
        function build(obj)
            %--------------------------------------------------------------
            if strcmpi(obj.coil_mode,'rx')
                obj.matrix.a_Is = [];
                return
            end
            %--------------------------------------------------------------
            Is_array = obj.Is.getvalue();
            % --- check changes
            is_changed = 1;
            if isequal(Is_array,obj.matrix.Is_array)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.Is_array = Is_array;
            %--------------------------------------------------------------
            nb_edge = obj.parent_model.parent_mesh.nb_edge;
            edge = obj.parent_model.parent_mesh.edge;
            node = obj.parent_model.parent_mesh.node;
            cedge = obj.parent_model.parent_mesh.cedge;
            vedge = zeros(3,nb_edge);
            for i = 1:3
                vedge(i,:) = node(i,edge(2,:)) - node(i,edge(1,:));
            end
            %--------------------------------------------------------------
            % a_vec = obj.getanode('node',cedge);
            % obj.matrix.a_Is = dot(a_vec,vedge).';
            % ---
            mu0 = 4*pi*1e-7;
            h_vec = obj.getbnode('node',cedge) ./ mu0;
            obj.matrix.h_Is = dot(h_vec,vedge).';
            %--------------------------------------------------------------
            obj.build_done = 1;
        end
    end
    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            % obj.parent_model.matrix.a_Is = ...
            %     obj.parent_model.matrix.a_Is + obj.matrix.a_Is;
            %--------------------------------------------------------------
            obj.parent_model.matrix.h_Is = ...
                obj.parent_model.matrix.h_Is + obj.matrix.h_Is;
            %--------------------------------------------------------------
        end
    end
    % --- postpro
    methods
        function getcircuitquantity(obj)
                
        end
    end
    % ----------------------------------------------------------------------------
    methods (Access = protected)
      function cpObj = copyElement(obj)
         % --- shallow copy of all properties
         cpObj = copyElement@matlab.mixin.Copyable(obj);
         % --- deep copy of of selected properties
         cpObj.turn = {};
         for i = 1:length(obj.turn)
            cpObj.turn{i} = copy(obj.turn{i});
         end
      end
   end
end


