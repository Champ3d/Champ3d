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

classdef OxyCoil4 < Xhandle
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
        function obj = OxyCoil4(args)
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
            nbplate = length(obj.mplate);
            % ---
            if nbplate == 2
                if obj.mplate{1}.z > obj.mplate{2}.z
                    mpdown = obj.mplate{2};
                    obj.mplate{2} = obj.mplate{1};
                    obj.mplate{1} = mpdown;
                end
            end
            % ---
            obj.makeimage_in;
            obj.makeimage_up;
            obj.makeimage_down;
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
                Linterne=0;
                for i = 1:length(obj.turn)
                   Linterne=Linterne + obj.turn{i}.getlinterne("I",1);
                end
                L=L+Linterne;
                obj.L = L;
            end
       end
       function M = getM(obj, coil_obj)
            if nargin <= 1
                error('Erreur : besoin de 2 bobines pour calculer la mutuelle');

            end
            % ---
            obj.getflux(coil_obj);
            M = coil_obj.flux/obj.I;
            % ---
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
            if isa(coil_obj,'OxyCoil4')
                for i = 1:length(coil_obj.turn)
                    rx = coil_obj.turn{i};
                    % ---
                    flux_ = 0;
                    % ---
                    for j = 1:length(obj.turn)
                        tx = obj.turn{j};
                        % ---
                        ft_ = tx.getflux("turn_obj",rx,"I",obj.I);
                        flux_ = flux_ + ft_;
                    end
                    % ---
                    for j = 1:length(obj.imagecoil_in)
                        cx = obj.imagecoil_in{j};
                        for k = 1:length(cx.turn)
                            tx = cx.turn{k};
                            % ---
                            ft_ = tx.getflux("turn_obj",rx,"I",cx.I);
                            flux_ = flux_ + ft_;
                        end
                    end
                    % ---
                    coil_obj.flux = coil_obj.flux + flux_;
                end
            end
            % ---
            fl = coil_obj.flux;
        end
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
            A = zeros(3,size(args.node,2));
            node_in   = args.node(:, id_in);
            node_up   = args.node(:, id_up);
            node_down = args.node(:, id_do);
            % --- XTODO --- up, down
            for i = 1:length(obj.turn)
                tx = obj.turn{i};
                A(:,id_in) = A(:,id_in) + tx.getanode("node",node_in,"I",obj.I);
            end
            % ---
            obj.makeimage_in;
            for j = 1:length(obj.imagecoil_in)
                cx = obj.imagecoil_in{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    A(:,id_in) = A(:,id_in) + tx.getanode("node",node_in,"I",cx.I);
                end
            end
            % ---
            for j = 1:length(obj.imagecoil_up)
                cx = obj.imagecoil_up{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    A(:,id_up) = A(:,id_up) + tx.getanode("node",node_up,"I",cx.I);
                end
            end
            % ---
            for j = 1:length(obj.imagecoil_down)
                cx = obj.imagecoil_down{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    A(:,id_do) = A(:,id_do) + tx.getanode("node",node_down,"I",cx.I);
                end
            end
        end
        function fl = getbds(obj,coil_obj)
            % ---
            if nargin <= 1 
                coil_obj = obj;
            end
            % ---
            obj.makeimage_in;
            % ---
            coil_obj.flux = 0;
            % ---
            if isa(coil_obj,'OxyCoil4')
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
            for j = 1:length(obj.imagecoil_in)
                cx = obj.imagecoil_in{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    B(:,id_in) = B(:,id_in) + tx.getbnode("node",node_in,"I",cx.I);
                end
            end
            % ---
            for j = 1:length(obj.imagecoil_up)
                cx = obj.imagecoil_up{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    B(:,id_up) = B(:,id_up) + tx.getbnode("node",node_up,"I",cx.I);
                end
            end
            % ---
            for j = 1:length(obj.imagecoil_down)
                cx = obj.imagecoil_down{j};
                for k = 1:length(cx.turn)
                    tx = cx.turn{k};
                    B(:,id_do) = B(:,id_do) + tx.getbnode("node",node_down,"I",cx.I);
                end
            end
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
            obj.imagecoil_up = {};
            nbplate = length(obj.mplate);
            if nbplate == 0
                return
            end
            % ---
            if nbplate == 1
                imorder = 1;
            elseif nbplate == 2
                imorder = zeros(2, 2*obj.imagelevel);
                imorder(1,:) = repmat([1 2],1,obj.imagelevel);
                imorder(2,:) = repmat([2 1],1,obj.imagelevel);
            end
            % ---
            imcoil = {};
            for i = 1:length(obj.mplate)
                imor = imorder(i,:);
                k = 0;
                for j = 1:length(imor)
                    k = k + 1;
                    % ---
                    if k == 1
                        c0 = obj;
                    else
                        c0 = imcoil{end};
                    end
                    % ---
                    zmir  = obj.mplate{imor(j)}.z;
                    alpha = (obj.mplate{imor(j)}.mur - 1) / (obj.mplate{imor(j)}.mur + 1);
                    if i == 1
                        expo = 2*k - 1;   
                    else
                        expo = 2*k - 2;   
                    end
                    coeI = (1+alpha) * alpha^k;
                    % ---
                    imc = c0';
                    imc.mplate = {};
                    imc.zmirrow(zmir);
                    imc.I = coeI * obj.I;
                    % ---
                    imcoil{end+1} = imc;
                end
            end
            % ---
            iremove = [2*(1:obj.imagelevel), 2*obj.imagelevel+2*(1:obj.imagelevel) - 1];
            imcoil(iremove) = [];
            % ---
            if nbplate == 2
                alpha = (obj.mplate{2}.mur - 1) / (obj.mplate{2}.mur + 1);
                imc = obj';
                imc.mplate = {};
                imc.I = (1+alpha) * obj.I;
                % ---
                imcoil{end+1} = imc;
            end
            % ---
            obj.imagecoil_up = imcoil;
        end
        function makeimage_down(obj)
            % --- XTODO
            obj.imagecoil_down = {};
            nbplate = length(obj.mplate);
            if nbplate == 0
                return
            end
            % ---
            if nbplate == 1
                imorder = 1;
            elseif nbplate == 2
                imorder = zeros(2, 2*obj.imagelevel);
                imorder(1,:) = repmat([2 1],1,obj.imagelevel);
                imorder(2,:) = repmat([1 2],1,obj.imagelevel);
            end
            % ---
            imcoil = {};
            for i = 1:length(obj.mplate)
                imor = imorder(i,:);
                k = 0;
                for j = 1:length(imor)
                    k = k + 1;
                    % ---
                    if k == 1 
                        c0 = obj;
                    else 
                        c0 = imcoil{end};
                    end
                    % ---
                    zmir  = obj.mplate{imor(j)}.z;
                    alpha = (obj.mplate{imor(j)}.mur - 1) / (obj.mplate{imor(j)}.mur + 1);
                    if i == 1
                        expo = 2*k - 2;   
                    else
                        expo = 2*k - 1;   
                    end
                    coeI = (1+alpha) * alpha^k;
                    % ---
                    imc = c0';
                    imc.mplate = {};
                    imc.zmirrow(zmir);
                    imc.I = coeI * obj.I;
                    % ---
                    imcoil{end+1} = imc;
                end
            end
            % ---
            iremove = [2*(1:obj.imagelevel), 2*obj.imagelevel+2*(1:obj.imagelevel) - 1];
            imcoil(iremove) = [];
            % ---
            if nbplate == 2
                alpha = (obj.mplate{1}.mur - 1) / (obj.mplate{1}.mur + 1);
                imc = obj';
                imc.mplate = {};
                imc.I = (1+alpha) * obj.I;
                % ---
                imcoil{end+1} = imc;
            end
            % ---
            obj.imagecoil_down = imcoil;
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


