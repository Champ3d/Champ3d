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

classdef  OxyMplate < Xhandle
    properties
        center = [0 0]
        z1 = 0
        z2=0
        r = 1e-4
        epaisseur =1e-6
        coilsystem= OxyCoilSystem()
        mur=1000
        alpha=1.32
        beta=2
        kappa=6.47
        fr
        % ---
        dom
    end

    % --- tempo
    properties
        B
        
    end
    properties (Constant)
        rmin = 1e-4
    end
    properties (Hidden)
        rnum = 30
        anum = 50
        znum= 50
    end
    % --- Constructors
    methods
        function obj = OxyMplate (args)
            arguments
                args.center {mustBeNumeric} = [0 0]
                args.z1 {mustBeNumeric}      = 0
                args.z2 {mustBeNumeric}      = 0
                args.r {mustBePositive}    = 1e-4
                args.epaisseur {mustBePositive} = 1e-6
                args.coilsystem  OxyCoilSystem = OxyCoilSystem()       
                args.mur {mustBePositive}    = 1000  
                args.alpha {mustBePositive}    = 1.32  
                args.beta {mustBePositive}    = 2 
                args.kappa {mustBePositive}    = 6.47  
                args.fr {mustBePositive}    = 1000  
            end
            % ---
            obj@Xhandle;
            % ---
           
            % ---
            obj.center = args.center;
            obj.z1 = args.z1;
            obj.z2 = args.z2;
            obj.r = args.r;
            obj.epaisseur = args.epaisseur;
            obj.coilsystem = args.coilsystem;
            obj.mur=args.mur;
            obj.alpha=args.alpha;
            obj.beta=args.beta;
            obj.kappa=args.kappa;
            obj.fr=args.fr;
            % ---
        end
    end
    % ---
    methods
       function setup(obj)
         obj.coilsystem.setup();
         obj.makedom();
       end


    end







    methods

       function plot(obj,args)
                    arguments
                        obj
                        args.color = [0.8 0.2 0.2]
                        args.facealpha = 1
                        
                    end
                
                    cen = obj.center;
                    th = linspace(0,2*pi,200);
                
                   
                    x = [0, obj.r*cos(th)];
                    y = [0, obj.r*sin(th)];
                
                    % --- disque bas
                    z1 = obj.z1 * ones(size(x));
                    fill3(x+cen(1), y+cen(2), z1, args.color, 'FaceAlpha', args.facealpha, 'EdgeColor','none');
                    hold on
                
                    % --- disque haut
                    z2 = obj.z2 * ones(size(x));
                    fill3(x+cen(1), y+cen(2), z2, args.color,'FaceAlpha', args.facealpha, 'EdgeColor','none');
                
                    
                    th2 = linspace(0,2*pi,100);
                    z = linspace(obj.z1,obj.z2,2);
                    [TH,Z] = meshgrid(th2,z);
                
                    X = cen(1) + obj.r*cos(TH);
                    Y = cen(2) + obj.r*sin(TH);
                
                    surf(X,Y,Z,'FaceColor',args.color,'FaceAlpha',args.facealpha,'EdgeColor','none');
                
                    axis equal
                    xlabel("x (m)"); ylabel("y (m)"); zlabel("z (m)");
                    view(3)
       end
  end


     
  
  methods
     

      function  B = getbnode(obj)
              arguments
                obj
       
            end
        
            B = 0;
            for i = 1:length(obj.coilsystem.coil)
                B = B + obj.coilsystem.coil{i}.getbnode("node",obj.dom.node);
            end

         end




         function perte=getperte(obj)
            
             B=obj.getbnode;
             V = obj.dom.volume(:).';   
             cst=(obj.kappa*obj.fr^(obj.alpha));
             p = cst * sum(abs(B).^obj.beta, 1);
             perte = sum(p .* V); 

         end

     end





























 methods (Access = protected)
        function makedom(obj)
          cen = obj.center;

                x_ = [];
                y_ = [];
                s_ = [];
                
                R = 0.9999999*obj.r;
                
                
                u = linspace(0, 1, obj.rnum);
                p=0.7;
                %rdiv = R * sqrt(u);
                rdiv = R * u.^p;
                rcen = (rdiv(1:end-1) + rdiv(2:end))/2;
                
              
                adiv = linspace(0, 2*pi, obj.anum+1);   
                acen = (adiv(1:end-1) + adiv(2:end))/2;
                da = adiv(2) - adiv(1);
                
               
                for i = 1:length(rcen)
                    x_ = [x_, rcen(i).*cos(acen)];
                    y_ = [y_, rcen(i).*sin(acen)];
                    s_ = [s_, ((rdiv(i+1)^2 - rdiv(i)^2) * da / 2) * ones(1, length(acen))];
                end
                
                %---ajout du centre du cercle

                x_=[x_,0];
                y_=[y_,0];
                s_ = [s_, pi * rdiv(2)^2];


               % --- points sur les bords (je veux juste visualiser)
                x_bord = [];
                y_bord = [];
                for i = 1:length(rdiv)
                    x_bord = [x_bord, rdiv(i).*cos(adiv)];
                    y_bord = [y_bord, rdiv(i).*sin(adiv)];
                end
                z_bord = obj.z1 .* ones(size(x_bord));
                obj.dom.nodebord = [x_bord+cen(1); y_bord+cen(2); z_bord];

                %------- discrétisation en z
                                
                obj.dom.node = [];
                v_ = [];
                obj.dom.area = s_;
                
                cen = obj.center;
                
                z1 = min(obj.z1, obj.z2);
                z2 = max(obj.z1, obj.z2);
                
                zdiv = linspace(z1, z2, obj.znum+1);
                zcen = (zdiv(1:end-1) + zdiv(2:end))/2;
                dz   = diff(zdiv);
                
                for i = 1:length(zcen)
                    z_ = zcen(i) * ones(size(x_));
                    obj.dom.node = [obj.dom.node, [x_+cen(1); y_+cen(2); z_]];
                    v_ = [v_, dz(i) * s_];
                end
                
                obj.dom.volume = v_;

        end
    end

   







end


