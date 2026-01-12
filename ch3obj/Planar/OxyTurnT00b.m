%--------------------------------------------------------------------------
% This code is written by: Nora TODJIHOUNDE, H-K.Bui, 2025
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

classdef OxyTurnT00b < OxyTurn
    properties
        center = [0 0]
        z = 0
        ri = 0
        ro = 0
        dir = 0
        openi = 0
        openo = 0
        pole = +1  
        rwire=1e-6  % +1 or -1
        % ---
        wire
        dom
    end
    % --- tempo
    properties
        A
        flux
    end
    properties (Constant)
        rmin = 1e-4
    end
    properties (Hidden)
        rnum = 10
        onum = 10
    end
    % --- Constructors
    methods
        function obj = OxyTurnT00b(args)
            arguments
                args.center {mustBeNumeric} = [0 0]
                args.z {mustBeNumeric}      = 0
                args.ri {mustBePositive}    = 1e-4
                args.ro {mustBePositive}    = 0
                args.rwire {mustBePositive} = 1e-6
                args.dir {mustBeNumeric}    = 0         % angle in deg
                args.openi {mustBePositive} = 0         % angle in deg
                args.openo {mustBePositive} = 0         % angle in deg
                args.pole {mustBeNumeric}   = +1        % +1 or -1
            end
            % ---
            obj@OxyTurn;
            % ---
            if args.ro <= args.ri
                error("#ro must be > #ri");
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % ---
    methods
        function setup(obj)
            obj.makewire;
        end
    end




    % ---
    methods
        
        function turnflux = getflux(obj, args)
            arguments
                obj
                args.turn_obj {mustBeA(args.turn_obj,"OxyTurn")}
                args.I = 1
            end
            % ---
            if isfield(args,"turn_obj")
                turn_obj = args.turn_obj;
                % ---
                obj.setup;
                turn_obj.setup;
            else
                turn_obj = obj;
                % ---
                obj.setup;
            end
            % ---
            A = obj.getanode("node",turn_obj.dom.node,"I",args.I);
            turnflux = sum( A(1,:).*obj.dom.len(1,:) + A(2,:).*obj.dom.len(2,:) + A(3,:).*obj.dom.len(3,:) ) ...
                       .* turn_obj.pole; % ds = Oz = +1 (pole)
        end


      function A = getanode(obj, args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
                args.I = 1
            end
            % ---
            if ~isfield(args,"node")
                A = [];
                return
            end
            % ---
            A = 0;
            for i = 1:length(obj.wire)
                A = A + obj.wire{i}.getanode("node",args.node,"I",args.I);
            end
      end


      function turnflux = getbds(obj, args)
            arguments
                obj
                args.turn_obj {mustBeA(args.turn_obj,"OxyTurn")}
                args.I = 1
            end
            % ---
            if isfield(args,"turn_obj")
                turn_obj = args.turn_obj;
                % ---
                obj.setup;
                turn_obj.setup;
            else
                turn_obj = obj;
                % ---
                obj.setup;
            end
            % ---
            turnflux.B = obj.getbnode("node",turn_obj.dom.node,"I",args.I);
            turnflux.flux = sum(turnflux.B(3,:) .* turn_obj.dom.area) .* turn_obj.pole; % ds = Oz = +1 (pole)
        end










        function B = getbnode(obj, args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
                args.I = 1
            end
            % ---
            if ~isfield(args,"node")
                B = [];
                return
            end
            % ---
            B = 0;
            for i = 1:length(obj.wire)
                B = B + obj.wire{i}.getbnode("node",args.node,"I",args.I);
            end
        end
    end

















    % ---
    methods
        function rotate(obj,angle)
            obj.dir = obj.dir + angle;
        end
        function translate(obj,distance)
            obj.center = obj.center + distance(1:2);
            if length(distance) == 3
                obj.z = obj.z + distance(3);
            end
        end
        function scale(obj,distance)
            % ---
            ri0 = obj.ri;
            ro0 = obj.ro;
            % ---
            argleni = ri0 * obj.openi/180*pi;
            argleno = ro0 * obj.openo/180*pi;
            if argleno <= 2*distance || ro0 <= ri0 + 2*distance
                obj = OxyTurn;
                return
            end
            % ---
            a1 = argleni;
            a2 = argleno;
            % ---
            b1 = a1*(ro0 - ri0)/(a2 - a1);
            axi = 2*distance;
            b2 = (axi - a1)*b1/a1;
            % ---
            ri_ = ri0 + b2;
            if ri_ <= obj.ri + distance
                obj.ri = obj.ri + distance;
            else
                obj.ri = ri_;
            end
            % ---
            axi = a1*(b1 + (obj.ri - ri0))/b1;
            % ---
            obj.ro = obj.ro - distance;
            % ---
            oai = interp1([a1/ri0, a2/ro0], [sind(obj.openi), sind(obj.openo)], axi/obj.ri);
            oai = asind(oai);
            % ---
            axo = a1*(b1 + (obj.ro - ri0))/b1;
            oao = interp1([a1/ri0, a2/ro0], [sind(obj.openi), sind(obj.openo)], axo/obj.ro);
            oao = asind(oao);
            % ---
            obj.openi = oai - distance/axi*oai;
            obj.openo = oao - distance/axo*oao;
            % ---
        end
        function plot(obj,args)
            arguments
                obj
                args.color = 'b'
                args.linewidth = 2
            end
            % ---
            obj.setup;
            % ---
            for i = 1:length(obj.wire)
                obj.wire{i}.plot('color',args.color,'linewidth',args.linewidth); hold on
            end
        end
    end
    % ---
    methods (Access = protected)
        function makewire(obj)
            % --- WIRE
            obj.wire = {};
            % ---
            cen = f_tocolv(obj.center);
            ai1 = obj.dir - obj.openi/2;
            ao1 = obj.dir - obj.openo/2;
            P11 = [obj.ri*cosd(ai1); obj.ri*sind(ai1)];
            P12 = [obj.ro*cosd(ao1); obj.ro*sind(ao1)];
            wire01 = OxyStraightWire("P1",P11+cen,"P2",P12+cen,"z",obj.z,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire01;
            % ---
            ai2 = obj.dir + obj.openi/2;
            ao2 = obj.dir + obj.openo/2;
            P21 = [obj.ri*cosd(ai2); obj.ri*sind(ai2)];
            P22 = [obj.ro*cosd(ao2); obj.ro*sind(ao2)];
            wire02 = OxyStraightWire("P1",P21+cen,"P2",P22+cen,"z",obj.z,"signI",-1*obj.pole);
            % ---
            obj.wire{end+1} = wire02;
            % -------------------------------------------------------------------
            wire03 = OxyArcWire("z",obj.z,"center",cen,"phi1",ai1,"phi2",ai2,"r",obj.ri,"signI",-1*obj.pole);
            % ---
            obj.wire{end+1} = wire03;
            % ---
            wire04 = OxyArcWire("z",obj.z,"center",cen,"phi1",ao1,"phi2",ao2,"r",obj.ro,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire04;
            % -------------------------------------------------------------------
            % --- DOM
               cen = f_tocolv(obj.center); cx = cen(1); cy = cen(2);

               [ri,ro,thetai ,thetao]=reduction(obj.ri,obj.ro,obj.openi,obj.openo,obj.rwire,obj.rwire);
                %ri = obj.ri+obj.rwire; ro = obj.ro-obj.rwire;
                rnum = obj.rnum; onum = obj.onum;


                %[ri2,ro2,thetai2 ,thetao2]=reduction(ri1,ro1,thetai1,thetao1,d1,d)
    
                ai1 = obj.dir - thetai/2;       
                ao1 = obj.dir - thetao/2;       
                ai2 = obj.dir + thetai/2;      
                ao2 = obj.dir + thetao/2;       
    
                P11 = [ri*cosd(ai1); ri*sind(ai1)] + cen;   
                P12 = [ro*cosd(ao1); ro*sind(ao1)] + cen;   
                P21 = [ri*cosd(ai2); ri*sind(ai2)] + cen;   
                P22 = [ro*cosd(ao2); ro*sind(ao2)] + cen;   

                  X = []; Y = []; L = [];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Arc externe  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                
                    n_ext = 2*onum;
                    delta_alpha_deg = (ao2 - ao1) / n_ext;
                    alphak_deg = ao1 + (0:n_ext)*delta_alpha_deg;         % <-- 0:n_ext
                    alpha_mid_deg = 0.5*(alphak_deg(1:end-1) + alphak_deg(2:end));
                
                  
                      xmid = cx + ro * cosd(alpha_mid_deg);
                      ymid = cy + ro * sind(alpha_mid_deg);
                      l = ro * deg2rad(delta_alpha_deg);
                      X=[X xmid];
                      Y=[Y ymid];


                       %-------------------
                        xpoints=cx+ro*cosd(alphak_deg);
                        ypoints=cy+ro*sind(alphak_deg);
                        ux=xpoints(2:end)-xpoints(1:end-1);
                        uy=ypoints(2:end)-ypoints(1:end-1);
                        uz=zeros(size(uy));
                        u=[ux;uy;uz];
                        L=[L u];
                  


%            
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Coté oblique haut%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 
                 xdroite = linspace(P21(1), P22(1), rnum+1);
                 ydroite = linspace(P21(2), P22(2), rnum+1);
                
                 longueur = (norm(P21-P22)/rnum)*ones(1,rnum);
                
                 xdroite_mid = (xdroite(1:end-1) + xdroite(2:end))/2;
                 ydroite_mid = (ydroite(1:end-1) + ydroite(2:end))/2;
                 xdroite_mid=xdroite_mid(end:-1:1);
                 ydroite_mid=ydroite_mid(end:-1:1);
                 longueur=longueur(end:-1:1);
                 X = [X xdroite_mid];
                 Y = [Y ydroite_mid];
                 %L = [L longueur];
                  %----------------------------------------------------------------------------
                   xdroite=xdroite(end:-1:1);
                   ydroite=ydroite(end:-1:1);
                   ux=xdroite(2:end)-xdroite(1:end-1);
                   uy=ydroite(2:end)-ydroite(1:end-1);
                   uz=zeros(size(uy));
                   u=[ux;uy;uz];
                   L=[L u];

                   
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%% Arc interne %%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
                 delta_alpha_deg = (ai2 - ai1) / onum;
                 alphak_deg = ai1 + (0:onum)*delta_alpha_deg;
                 alpha_mid_deg = 0.5*(alphak_deg(1:end-1) + alphak_deg(2:end));
             
            
                
                  xmid =flip (cx + ri * cosd(alpha_mid_deg));
                  ymid = flip(cy + ri * sind(alpha_mid_deg));
                  l = flip(ri * deg2rad(delta_alpha_deg));
                  X=[X xmid];
                  Y=[Y ymid];
                 % L=[L l];
                
                  %--------------------------------------------------

                        xpoints=flip(cx+ri*cosd(alphak_deg));
                        ypoints=flip(cy+ri*sind(alphak_deg));
                        ux=xpoints(2:end)-xpoints(1:end-1);
                        uy=ypoints(2:end)-ypoints(1:end-1);
                        uz=zeros(size(uy));
                        u=[ux;uy;uz];
                        L=[L u];

          
                
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Coté oblique bas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                  
                  xdroite=linspace(P11(1),P12(1),rnum+1);
                  ydroite=linspace(P11(2),P12(2),rnum+1);
                
                
                  longueur=(norm(P11-P12)/rnum)*ones(1,rnum);
                
                  xdroite_mid = (xdroite(1:end-1) + xdroite(2:end))/2;
                  ydroite_mid = (ydroite(1:end-1) + ydroite(2:end))/2;
                
                  X=[X xdroite_mid];
                  Y=[Y ydroite_mid];


                   ux=xdroite(2:end)-xdroite(1:end-1);
                   uy=ydroite(2:end)-ydroite(1:end-1);
                   uz=zeros(size(uy));
                   u=[ux;uy;uz];
                   L=[L u];
                  
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
                   %X = fliplr(X);
                   %Y = fliplr(Y);
                   %L = fliplr(L);     
                   %L = -L;            
               

                 obj.dom.node = [X;Y; obj.z .* ones(1,length(X))];
                 obj.dom.len  = L;

            % ---
        end
    end
end


