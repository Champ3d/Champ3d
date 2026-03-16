function imagesys = generateimage(c0,I, xmir, ymir, mur, k)


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
        turnmirpos =fmiry(turnpb.pos,ymir) ;
        turnmirI = -alpha * turnpb.I;
        %turnmirI = alpha * turnpb.I;

        turnmmplacepos = turnpb.pos;
        turnmmplaceI = (1-alpha) * turnpb.I;
        %turnmmplaceI = beta* turnpb.I;
             

         if turnmirpos(2) > ymir
            imagesys.addregion0(turnmirpos, turnmirI);
            imagesys.addregion1(turnmmplacepos,turnmmplaceI);
        else
            imagesys.addregion1(turnmirpos, turnmirI);
            imagesys.addregion0(turnmmplacepos,turnmmplaceI);
        end

    else
        
        turnmirpos = fmirx(turnpb.pos,xmir) ;
        turnmirI = -alpha * turnpb.I;
    
        turnmmplacepos = turnpb.pos;
        turnmmplaceI = (1-alpha) * turnpb.I;
    
        if turnmirpos(1) > xmir
            imagesys.addregion0(turnmirpos, turnmirI);
            imagesys.addregion2(turnmmplacepos,turnmmplaceI);
        else
            imagesys.addregion2(turnmirpos, turnmirI);
            imagesys.addregion0(turnmmplacepos,turnmmplaceI);
        end
    end
end

end






















