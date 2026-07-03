function imagesys = generateimage_brouillon(c0,I, xmir, ymir, mur, k)


alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;


imagesys = OxyImageSystem( ...
    "xmir", xmir, ...
    "ymir", ymir, ...
    "alpha", alpha, ...
    "beta", beta, ...
    "kmax", 2*k);




% probleme = 1 : interface horizontale
% probleme = 2 : interface verticale
probleme = 1;
turnmirpos=fmiry(c0,ymir);
turnmirI=alpha*I;
imagesys.addregion1(c0,I);

imagesys.addregion1(turnmirpos,turnmirI);


turnmmplacepos=c0;
turnmmplaceI=beta*I;
imagesys.addregion0(turnmmplacepos,turnmmplaceI);



for i = 2:k

    turnpb = imagesys.imageregion0{end};
    probleme = 3-probleme;

    if probleme == 1
      
        if (turnpb.pos(2)<ymir)
    
                turnmirpos =fmiry(turnpb.pos,ymir) ;
                turnmirI = -alpha * turnpb.I;
               
        
                turnmmplacepos = turnpb.pos;
                turnmmplaceI = (1-alpha) * turnpb.I;
              
                     
                 imagesys.addregion0(turnmirpos, turnmirI);
                 imagesys.addregion1(turnmmplacepos,turnmmplaceI);

         else
               turnmirpos =fmiry(turnpb.pos,ymir) ;
               turnmirI =(alpha/(1+alpha)) * turnpb.I;
                
        
                turnmmplacepos = turnpb.pos;
                turnmmplaceI =  turnpb.I/(1+alpha);
                imagesys.addregion1(turnmirpos, turnmirI);
                imagesys.addregion1(turnmmplacepos,turnmmplaceI);
           end
    end






    if(probleme==2)
       if(turnpb.pos(1)<xmir)
            turnmirpos = fmirx(turnpb.pos,xmir) ;
            turnmirI = -alpha * turnpb.I;
        
            turnmmplacepos = turnpb.pos;
            turnmmplaceI = (1-alpha) * turnpb.I;
            imagesys.addregion0(turnmirpos, turnmirI);
            imagesys.addregion2(turnmmplacepos,turnmmplaceI);

        else
         
            turnmirpos = fmirx(turnpb.pos,xmir) ;
            turnmirI = alpha/(1+alpha) * turnpb.I;
        
            turnmmplacepos = turnpb.pos;
            turnmmplaceI = turnpb.I/(1+beta);
            
            imagesys.addregion2(turnmmplacepos,turnmmplaceI);
            imagesys.addregion2(turnmirpos, turnmirI);
           
       end



    end


    newturn=imagesys.imageregion0{end};
    if(newturn.I==turnpb.I && newturn.pos(1)==turnpb.pos(1) && newturn.pos(2)==turnpb.pos(2))
        break;
    end
end


probleme = 2;

imagesys.addregion2(c0,I);
turnmirpos=fmirx(c0,xmir);
turnmirI=I/(alpha);
imagesys.addregion2(turnmirpos,turnmirI);
turnmirI=(1+alpha)*I/(alpha);
imagesys.addregion0(turnmirpos,turnmirI);



for i = 2:k

    turnpb = imagesys.imageregion0{end};
    probleme = 3-probleme;

    if probleme == 1
      
       if(turnpb.pos(2)<ymir)
    
                turnmirpos =fmiry(turnpb.pos,ymir) ;
                turnmirI = -alpha * turnpb.I;
               
        
                turnmmplacepos = turnpb.pos;
                turnmmplaceI = (1-alpha) * turnpb.I;
              
                     
                 imagesys.addregion0(turnmirpos, turnmirI);
                 imagesys.addregion1(turnmmplacepos,turnmmplaceI);


          else
               turnmirpos =fmiry(turnpb.pos,ymir) ;
               turnmirI =(alpha/(1+alpha)) * turnpb.I;
                
        
                turnmmplacepos = turnpb.pos;
                turnmmplaceI =  turnpb.I/(1+alpha);
                imagesys.addregion1(turnmirpos, turnmirI);
                imagesys.addregion1(turnmmplacepos,turnmmplaceI);
           end
    end






    if(probleme==2)
       if(turnpb.pos(1)<xmir )
            turnmirpos = fmirx(turnpb.pos,xmir) ;
            turnmirI = -alpha * turnpb.I;
        
            turnmmplacepos = turnpb.pos;
            turnmmplaceI = (1-alpha) * turnpb.I;
            imagesys.addregion0(turnmirpos, turnmirI);
            imagesys.addregion2(turnmmplacepos,turnmmplaceI);


        else
         
            turnmirpos = fmirx(turnpb.pos,xmir) ;
            turnmirI = alpha/(1+alpha) * turnpb.I;
        
            turnmmplacepos = turnpb.pos;
            turnmmplaceI = turnpb.I/(1+beta);
            
            imagesys.addregion2(turnmmplacepos,turnmmplaceI);
            imagesys.addregion2(turnmirpos, turnmirI);
           
       end



    end


    newturn=imagesys.imageregion0{end};
    if(newturn.I==turnpb.I && newturn.pos(1)==turnpb.pos(1) && newturn.pos(2)==turnpb.pos(2))
        break;
    end
end























end






















