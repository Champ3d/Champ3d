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

classdef OxyCoil < Xhandle
    properties
        I
        turn = {}
        L
        mplate = {}
        imagelevel = 1
    end
    properties
        imagecoil_in = {}
        imagecoil_up = {}
        imagecoil_down = {}
    end
    % --- tempo
    properties
        flux
    end
    % --- Constructors
    methods
        function obj = OxyCoil(args)
            arguments
                args.id = '-'
                args.I = 0
                args.imagelevel = 1
            end
            % ---
            obj@Xhandle;
            % ---
            obj <= args;
            % ---
        end
    end
    % ---
    methods
        function add_turn(obj,turn_obj)
            obj.turn{end+1} = turn_obj;
        end
        function add_mplate(obj,args)
            arguments
                obj
                args.mur = 1
                args.z = 0
                args.thickness = 0
                args.r = 0
            end
            % ---
            if length(obj.mplate) >= 2
                warning("Cannot add more than 2 magnetic plates !");
                return
            end
            % ---
            obj.mplate{end+1} = struct("mur",args.mur,"z",args.z, ...
                           "thickness",args.thickness,"r",args.r);
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
        function zmirrow(obj,zmirrow)
            for i = 1:length(obj.turn)
                distance = -2*(obj.turn{i}.z - zmirrow);
                obj.turn{i}.translate([0 0 distance]);
            end
            % ---
            obj.setup;
            % ---
        end
        % ---
        function setup(obj)
            % ---
            for i = 1:length(obj.turn)
                obj.turn{i}.setup;
            end
            % ---
        end
        % ---
        function plot(obj,args)
            arguments
                obj
                args.color = 'k'
                args.with_image = 0
            end
            % ---
            for i = 1:length(obj.turn)
                obj.turn{i}.plot("color",args.color);
            end
            % ---
            if args.with_image
                for i = 1:length(obj.imagecoil_in)
                    for j = 1:length(obj.imagecoil_in{i}.turn)
                        obj.imagecoil_in{i}.turn{j}.plot("color",f_color(i));
                    end
                end
            end
            % ---
            axis equal; xlabel("x (m)"); ylabel("y (m)"); zlabel("z (m)"); 
        end
    end
    % ---
    methods
        function L = getL(obj, coil_obj)
            if nargin <= 1
                coil_obj = obj;
            end
            % ---
            obj.getflux(coil_obj);
            L = coil_obj.flux/obj.I;
            % ---
            if isequal(obj,coil_obj)
                obj.L = L;
            end
        end
        function fl = getflux(obj,coil_obj)
            % ---
            if nargin <= 1 
                coil_obj = obj;
            end
            % ---
            obj.makeimage_in;
            % ---
            coil_obj.flux = 0;
            % ---
            if isa(coil_obj,'OxyCoil')
                for i = 1:length(coil_obj.turn)
                    rx = coil_obj.turn{i};
                    % ---
                    rx.B = 0;
                    rx.flux = 0;
                    % ---
                    for j = 1:length(obj.turn)
                        tx = obj.turn{j};
                        % ---
                        ft_ = tx.getflux("turn_obj",rx,"I",obj.I);
                        rx.B = rx.B + ft_.B;
                        rx.flux = rx.flux + ft_.flux;
                    end
                    % ---
                    for j = 1:length(obj.imagecoil_in)
                        cx = obj.imagecoil_in{j};
                        for k = 1:length(cx.turn)
                            tx = cx.turn{k};
                            % ---
                            ft_ = tx.getflux("turn_obj",rx,"I",obj.I);
                            rx.B = rx.B + ft_.B;
                            rx.flux = rx.flux + ft_.flux;
                        end
                    end
                    % ---
                    coil_obj.flux = coil_obj.flux + rx.flux;
                end
            end
            % ---
            fl = coil_obj.flux;
        end
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
            % --- XTODO
            if isempty(obj.mplate)
                id_in = 1:size(args.node,2);
                id_up = [];
                id_do = [];
            else
                [zdown, zup] = obj.zmplate;
                % ---
                id_in  = find(args.node(3,:) <= zup & args.node(3,:) >= zdown);
                id_up  = find(args.node(3,:) > zup);
                id_do  = find(args.node(3,:) < zdown);
                % ---
            end
            B = zeros(3,size(args.node,2));
            node_in   = args.node(:, id_in);
            node_up   = args.node(:, id_up);
            node_down = args.node(:, id_do);
            % --- XTODO --- up, down
            for i = 1:length(obj.turn)
                tx = obj.turn{i};
                B(:,id_in) = B(:,id_in) + tx.getbnode("node",node_in,"I",obj.I);
            end
            % ---
            obj.makeimage_in;
            for j = 1:length(obj.imagecoil_in)
                cx = obj.imagecoil_in{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    B(:,id_in) = B(:,id_in) + tx.getbnode("node",node_in,"I",cx.I);
                end
            end
            % ---
        end
    end
    methods (Access = protected)
        function makeimage_in(obj)
            % ---
            obj.imagecoil_in = {};
            nbplate = length(obj.mplate);
            % ---
            if nbplate == 0
                return
            end
            % --- order --- XTODO more than 2
            if nbplate == 1
                imorder = 1;
            elseif nbplate == 2
                imorder = zeros(2, 2 * obj.imagelevel);
                imorder(1,:) = repmat([1 2],1,obj.imagelevel);
                imorder(2,:) = repmat([2 1],1,obj.imagelevel);
            end
            % ---
            imcoil = {};
            for i = 1:length(obj.mplate)      % nb of series
                imor = imorder(i,:);
                k = 0;
                for j = 1:length(imor)        % plate after plate
                    k = k + 1;
                    if k == 1
                        c0 = obj;
                    else
                        c0 = imcoil{end};
                    end
                    % ---
                    zmir = obj.mplate{imor(j)}.z;
                    coeI = ((obj.mplate{imor(j)}.mur - 1) / (obj.mplate{imor(j)}.mur + 1)) ^ k;
                    % ---
                    imc = c0';
                    imc.mplate = {};    % !!!
                    imc.zmirrow(zmir);
                    imc.I = coeI * obj.I;
                    % ---
                    imcoil{end+1} = imc;
                end
            end
            % ---
            obj.imagecoil_in = imcoil;
            % ---
        end
        function makeimage_up(obj)
            % --- XTODO
            obj.imagecoil_up = {};
        end
        function makeimage_down(obj)
            % --- XTODO
            obj.imagecoil_down = {};
        end
        function [zdown, zup] = zmplate(obj)
            z = [];
            for i = 1:length(obj.mplate)
                z = [z obj.mplate{i}.z];
            end
            % ---
            zdown = min(z);
            zup = max(z);
        end
        function zimage = reflectz(obj,args)
            arguments
                obj
                args.zplate
                args.zturn
            end
            % ---
            zimage = args.zplate - (args.zturn - args.zplate);
            % ---
        end
    end
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


