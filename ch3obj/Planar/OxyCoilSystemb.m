%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef OxyCoilSystemb < Xhandle
    properties
        coil = {}
    end
    % --- tempo
    properties
        A
        B
    end
    % --- Constructors
    methods
        function obj = OxyCoilSystemb()
            obj@Xhandle;
        end
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function add_coil(obj,coil_obj)
            if iscell(coil_obj)
                for i = 1:length(coil_obj)
                    obj.coil{end+1} = coil_obj{i};
                end
            else
                obj.coil{end+1} = coil_obj;
            end
        end
        % -----------------------------------------------------------------
        function rotate(obj,angle)
            % ---
            for i = 1:length(obj.coil)
                obj.coil{i}.rotate(angle);
            end
            obj.setup;
            % ---
        end
        % -----------------------------------------------------------------
        function translate(obj,distance)
            % ---
            for i = 1:length(obj.coil)
                obj.coil{i}.translate(distance);
            end
            obj.setup;
            % ---
        end
        % -----------------------------------------------------------------
        function setup(obj)
            for i = 1:length(obj.coil)
                obj.coil{i}.setup;
            end
        end
        % -----------------------------------------------------------------
        function plot(obj)
            for i = 1:length(obj.coil)
                obj.coil{i}.plot("color",f_color(i));
            end
            % ---
            axis equal; xlabel("x (m)"); ylabel("y (m)"); zlabel("z (m)"); 
        end
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function L = getL(obj)
            nbcoil = length(obj.coil);
            L = zeros(nbcoil,nbcoil);
            for i = 1:nbcoil
                tx = obj.coil{i};
                for j = 1:nbcoil
                    rx = obj.coil{j};
                    if (j==i)
                      L(i,j) = tx.getL(rx);
                    else
                      L(i,j) = tx.getM(rx);
                    end
                end
            end
        end
        % -----------------------------------------------------------------
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
            A = 0;
            for i = 1:length(obj.coil)
                A = A + obj.coil{i}.getanode("node",args.node);
            end
        end
        % -----------------------------------------------------------------
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
            B = 0;
            for i = 1:length(obj.coil)
                B = B + obj.coil{i}.getbnode("node",args.node);
            end
        end
        % -----------------------------------------------------------------
    end
    methods (Access = protected)
      function cpObj = copyElement(obj)
         % --- shallow copy of all properties
         cpObj = copyElement@matlab.mixin.Copyable(obj);
         % --- deep copy of of selected properties
         cpObj.coil = {};
         for i = 1:length(obj.coil)
            cpObj.coil{i} = copy(obj.coil{i});
         end
      end
   end
end