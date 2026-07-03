function imagesys = generateimage_sg1(obj)

    c0=obj;
    I=obj.I;
    z1primaire=obj.mplate{1}.z;
    z1secondaire=obj.mplate{2}.z;
    epaisseur1=obj.mplate{1}.thickness;
    epaisseur2=obj.mplate{2}.thickness;
    mur=obj.mplate{1}.mur;
    imagelevel=obj.imagelevel;








alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;


imagesys = OxyImageSystemb( ...
    "kmax", imagelevel, ...
    "z1primaire", z1primaire, ...
    "z1secondaire", z1secondaire, ...
    "alpha", alpha, ...
    "beta", beta);

imagesys.setup();

zinterface = [z1primaire - epaisseur1;z1primaire;z1secondaire;z1secondaire + epaisseur2];


interfaceOrder = repmat([2 1 3 4],1,imagelevel);
a_traiter_region1 = {};
a_traiter_region2 = {};
a_traiter_region3 = {};
a_traiter_region4 = {};
a_traiter_region5 = {};

imagesys.addregion3(c0,3,2);
a_traiter_region3{end+1} = imagesys.imageregion3{end};
        
      for i=1:length(interfaceOrder)
           interface=interfaceOrder(i); 
           switch interface
                case 2
                    [imagesys, a_traiter_region2, a_traiter_region3] = traiter_interface2(imagesys, a_traiter_region2, a_traiter_region3, zinterface, alpha, beta);
            
                 case 1
                     [imagesys, a_traiter_region1, a_traiter_region2] = traiter_interface1(imagesys, a_traiter_region1, a_traiter_region2, zinterface, alpha, beta);

            
                case 3
              
                    [imagesys, a_traiter_region3, a_traiter_region4]=traiter_interface3(imagesys, a_traiter_region3, a_traiter_region4, zinterface, alpha, beta);
            
               case 4
                  [imagesys, a_traiter_region4, a_traiter_region5] = traiter_interface4(imagesys, a_traiter_region4, a_traiter_region5, zinterface, alpha, beta);
          end
        
      end




end

%%
%-------------------------------------- fonction locale sous groupe-----------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%



