function imagesys = generation_image(c0,I, xmir, ymir, mur, k)


alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;


imagesys = OxyImageSystem( ...
    "xmir", xmir, ...
    "ymir", ymir, ...
    "alpha", alpha, ...
    "beta", beta, ...
    "kmax", 2*k);


imagesys.setup();
deja_air = {};
deja_noyau = {};
a_faire_air={};
a_faire_noyau={};

imagesys.addregionair(c0, I, "source");

%%
%-----première itération
%----sur l'horizontal
interface = 1;   

turnmirpos = fmiry(c0, ymir);
turnmirI   = alpha * I;
imagesys.addregionair(turnmirpos, turnmirI, interface);

turnmmplacepos = c0;
turnmmplaceI   = beta * I;
imagesys.addregionnoyau(turnmmplacepos, turnmmplaceI, interface);


%---sur la vertical

interface = 2;













deja_air{end+1} = struct("pos", pos, "I", I);



   for ik = 1:k
    
   
    sources_air   = imagesys.imageregionair;
    sources_noyau = imagesys.imageregionnoyau;

    a_faire_air   = extraire_nouveaux(sources_air, deja_air, {});
    a_faire_noyau = extraire_nouveaux(sources_noyau, deja_noyau, {});

  
    for interface = 1:2
        
       
    end





  deja_air   = [deja_air, a_faire_air];
  deja_noyau = [deja_noyau, a_faire_noyau];


end























end






















