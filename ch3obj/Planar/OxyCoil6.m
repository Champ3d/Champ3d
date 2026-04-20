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

classdef OxyCoil6 < Xhandle
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
        imagesys = []
    end
    % --- tempo
    properties
        flux
    end
    % --- Constructors
    methods
        function obj = OxyCoil6(args)
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
        function zmirrow(obj,zmir)
            for i = 1:length(obj.turn)
                distance = -2*(obj.turn{i}.z - zmir);
                obj.turn{i}.translate([0 0 distance]);
            end
            % ---
            obj.setup_basic;
            % ---
        end

       function rmirrow(obj,rmir)
            for i = 1:length(obj.turn)
               ro= rmir^2 / obj.turn{i}.ri;
               ri=rmir^2 / obj.turn{i}.ro;
                
               obj.turn{i}.ri=ri;
               obj.turn{i}.ro=ro;
            end
            % ---
            obj.setup_basic;
            % ---
        end



        function setup_basic(obj)
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

        end

        % ---
        function setup(obj)
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
            obj.generateimage;
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
            %obj.makeimage_in;
            % ---
            coil_obj.flux = 0;
            % ---
            if isa(coil_obj,'OxyCoil6')
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
            %obj.makeimage_in;
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
            %obj.makeimage_in;
            % ---
            coil_obj.flux = 0;
            % ---
            if isa(coil_obj,'OxyCoil6')
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

     function  generateimage(obj)
            
                c0=obj;
                z1primaire=obj.mplate{1}.z;
                z1secondaire=obj.mplate{2}.z;
                epaisseur1=obj.mplate{1}.thickness;
                epaisseur2=obj.mplate{2}.thickness;
                mur=obj.mplate{1}.mur;
                alpha = (mur - 1)/(mur + 1);
                beta  = 1 + alpha;
            
            
            obj.imagesys = OxyImageSystemb( ...
                "kmax", obj.imagelevel, ...
                "z1primaire", z1primaire, ...
                "z1secondaire", z1secondaire, ...
                "alpha", alpha, ...
                "beta", beta);
            
             obj.imagesys.setup();
            
            zinterface = [z1primaire - epaisseur1;z1primaire;z1secondaire;z1secondaire + epaisseur2];
            
               %-------------------------------------- sous groupe 1----------------------------------%
            interfaceOrder = repmat([2 1 3 4],1,obj.imagelevel);
            a_traiter_region1 = {};
            a_traiter_region2 = {};
            a_traiter_region3 = {};
            a_traiter_region4 = {};
            a_traiter_region5 = {};
            
            obj.imagesys.addregion3(c0,3,2);
            a_traiter_region3{end+1} =  obj.imagesys.imageregion3{end};
                    
                  for i=1:length(interfaceOrder)
                       interface=interfaceOrder(i); 
                       switch interface
                            case 2
                                [ obj.imagesys, a_traiter_region2, a_traiter_region3] = traiter_interface2( obj.imagesys, a_traiter_region2, a_traiter_region3, zinterface, alpha, beta);
                        
                             case 1
                                 [ obj.imagesys, a_traiter_region1, a_traiter_region2] = traiter_interface1( obj.imagesys, a_traiter_region1, a_traiter_region2, zinterface, alpha, beta);
            
                        
                            case 3
                          
                                [ obj.imagesys, a_traiter_region3, a_traiter_region4]=traiter_interface3( obj.imagesys, a_traiter_region3, a_traiter_region4, zinterface, alpha, beta);
                        
                           case 4
                              [ obj.imagesys, a_traiter_region4, a_traiter_region5] = traiter_interface4( obj.imagesys, a_traiter_region4, a_traiter_region5, zinterface, alpha, beta);
                      end
                    
                  end



                  %------------------------------------- sous groupe 2--------------------------------------------------------

                    interfaceOrder = repmat([3 4 2 1],1,obj.imagelevel);
                    a_traiter_region1 = {};
                    a_traiter_region2 = {};
                    a_traiter_region3 = {};
                    a_traiter_region4 = {};
                    a_traiter_region5 = {};
                    
                    
                    a_traiter_region3{end+1} = struct("coil",c0,"region",3,"next_interface",3,"deja_traite", false);
                            
                          for i=1:length(interfaceOrder)
                               interface=interfaceOrder(i); 
                               switch interface
                                    case 2
                                        [ obj.imagesys, a_traiter_region2, a_traiter_region3] = traiter_interface2( obj.imagesys, a_traiter_region2, a_traiter_region3, zinterface, alpha, beta);
                                
                                     case 1
                                         [ obj.imagesys, a_traiter_region1, a_traiter_region2] = traiter_interface1( obj.imagesys, a_traiter_region1, a_traiter_region2, zinterface, alpha, beta);
                    
                                
                                    case 3
                                  
                                        [ obj.imagesys, a_traiter_region3, a_traiter_region4]=traiter_interface3( obj.imagesys, a_traiter_region3, a_traiter_region4, zinterface, alpha, beta);
                                
                                   case 4
                                      [ obj.imagesys, a_traiter_region4, a_traiter_region5] = traiter_interface4( obj.imagesys, a_traiter_region4, a_traiter_region5, zinterface, alpha, beta);
                              end
                            
                          end

end

  function makeimage_in(obj)
            
            obj.imagecoil_in = {};

            if isempty(obj.imagesys)
                return
            end

            for i = 1:length(obj.imagesys.imageregion3)
                  obj.imagecoil_in{end+1} = obj.imagesys.imageregion3{i}.coil;
            end

             for i=1:length(obj.mplate)
                 imc=obj';
                 imc.zmirrow(obj.mplate{i}.z);
                 imc.rmirrow(obj.mplate{i}.r);
                 obj.imagecoil_in{end+1} =imc;

             end


  end
        function makeimage_up(obj)
            obj.imagecoil_up = {};

            if isempty(obj.imagesys)
                return
            end


             for i = 1:length(obj.imagesys.imageregion4)
                  obj.imagecoil_up{end+1} = obj.imagesys.imageregion4{i}.coil;
            end
        end







        function makeimage_down(obj)
           obj.imagecoil_down = {};

            if isempty(obj.imagesys)
                return
            end
            
             for i = 1:length(obj.imagesys.imageregion2)
                  obj.imagecoil_down{end+1} = obj.imagesys.imageregion2{i}.coil;
             end


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


