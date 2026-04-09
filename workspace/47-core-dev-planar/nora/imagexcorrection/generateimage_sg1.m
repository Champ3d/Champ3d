function imagesys = generateimage_sg1(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel)

alpha = (mur - 1)/(mur + 1);
beta  = 1 + alpha;


imagesys = OxyImageSystem( ...
    "kmax", imagelevel, ...
    "z1primaire", z1primaire, ...
    "z1secondaire", z1secondaire, ...
    "epaisseur", epaisseur, ...
    "alpha", alpha, ...
    "beta", beta);

imagesys.setup();

zinterface = [z1primaire - epaisseur;z1primaire;z1secondaire;z1secondaire + epaisseur];


interfaceOrder = repmat([2 1 3 4],1,imagelevel);
a_traiter_region1 = {};
a_traiter_region2 = {};
a_traiter_region3 = {};
a_traiter_region4 = {};
a_traiter_region5 = {};

imagesys.addregion3(c0,I,3,2);
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

function [imagesys, a_traiter_region2, a_traiter_region3] = traiter_interface2(imagesys, a_traiter_region2, a_traiter_region3, zinterface, alpha, beta)

z_int = zinterface(2);

% -------- région 2 --------
if ~isempty(a_traiter_region2)
    for i = 1:length(a_traiter_region2)
        source = a_traiter_region2{i};

        if source.next_interface == 2 && ~source.deja_traite

            if source.pos(2) < z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = -alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = (1 - alpha) * source.I;

                imagesys.addregion2(imagemirpos, imagemirI, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

                imagesys.addregion3(imagetransmispos, imagetransmisI, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / (-alpha);
                imagetransmisI = (1 - alpha) * source.I / (-alpha);

                imagesys.addregion2(imageinitialpos, imageinitialI, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

                imagesys.addregion3(imagetransmispos, imagetransmisI, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};
            end

            a_traiter_region2{i}.deja_traite = true;
        end
    end
    a_traiter_region2 = supprimer_source(a_traiter_region2);
end

% -------- région 3 --------
if ~isempty(a_traiter_region3)
    for i = 1:length(a_traiter_region3)
        source = a_traiter_region3{i};

        if source.next_interface == 2 && ~source.deja_traite

            if source.pos(2) > z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = beta * source.I;

                imagesys.addregion3(imagemirpos, imagemirI, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion2(imagetransmispos, imagetransmisI, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / alpha;
                imagetransmisI = beta * source.I / alpha;

                imagesys.addregion3(imageinitialpos, imageinitialI, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion2(imagetransmispos, imagetransmisI, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
            end

            a_traiter_region3{i}.deja_traite = true;
        end
    end
    a_traiter_region3 = supprimer_source(a_traiter_region3);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [imagesys, a_traiter_region1, a_traiter_region2] = traiter_interface1(imagesys, a_traiter_region1, a_traiter_region2, zinterface, alpha, beta)

z_int = zinterface(1);

%%%%%%%%%%%%%%%%%%%%% -------- région 1 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region1)
    for i = 1:length(a_traiter_region1)
        source = a_traiter_region1{i};

        if source.next_interface == 1 && ~source.deja_traite

            if source.pos(2) < z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = beta * source.I;

                imagesys.addregion1(imagemirpos, imagemirI, 1, 1);
                

                imagesys.addregion2(imagetransmispos, imagetransmisI, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / alpha;
                imagetransmisI = beta * source.I / alpha;

                imagesys.addregion1(imageinitialpos, imageinitialI, 1, 1);
                

                imagesys.addregion2(imagetransmispos, imagetransmisI, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
            end

            a_traiter_region1{i}.deja_traite = true;
        end
    end

    a_traiter_region1 = supprimer_source(a_traiter_region1);
end

%%%%%%%%%%%%%%%%%%%%% -------- région 2 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region2)
    for i = 1:length(a_traiter_region2)
        source = a_traiter_region2{i};

        if source.next_interface == 1 && ~source.deja_traite

            if source.pos(2) > z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = -alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = (1 - alpha) * source.I;

                imagesys.addregion2(imagemirpos, imagemirI, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

                imagesys.addregion1(imagetransmispos, imagetransmisI, 1, 1);
               
            else
                 imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / (-alpha);
                imagetransmisI = (1 - alpha) * source.I / (-alpha);

                imagesys.addregion2(imageinitialpos, imageinitialI, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
                imagesys.addregion1(imagetransmispos, imagetransmisI, 1, 1);
         
            end

            a_traiter_region2{i}.deja_traite = true;
        end
    end

    a_traiter_region2 = supprimer_source(a_traiter_region2);
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [imagesys, a_traiter_region3, a_traiter_region4] = traiter_interface3(imagesys, a_traiter_region3, a_traiter_region4, zinterface, alpha, beta)

   z_int = zinterface(3);

%%%%%%%%%%%%%%%%%%%%% -------- région 3 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region3)
    for i = 1:length(a_traiter_region3)
        source = a_traiter_region3{i};

        if source.next_interface == 3 && ~source.deja_traite

            if source.pos(2) < z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = beta * source.I;

                imagesys.addregion3(imagemirpos, imagemirI, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion4(imagetransmispos, imagetransmisI, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / alpha;
                imagetransmisI = beta * source.I / alpha;

                imagesys.addregion3(imageinitialpos, imageinitialI, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion4(imagetransmispos, imagetransmisI, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};
            end

            a_traiter_region3{i}.deja_traite = true;
        end
    end

    a_traiter_region3 = supprimer_source(a_traiter_region3);
end

%%%%%%%%%%%%%%%%%%%%% -------- région 4 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region4)
    for i = 1:length(a_traiter_region4)
        source = a_traiter_region4{i};

        if source.next_interface == 3 && ~source.deja_traite

            if source.pos(2) > z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = -alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = (1 - alpha) * source.I;

                imagesys.addregion4(imagemirpos, imagemirI, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

                imagesys.addregion3(imagetransmispos, imagetransmisI, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};


            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / (-alpha);
                imagetransmisI = (1 - alpha) * source.I / (-alpha);

                imagesys.addregion4(imageinitialpos, imageinitialI, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

                imagesys.addregion3(imagetransmispos, imagetransmisI, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};
            end

            a_traiter_region4{i}.deja_traite = true;
        end
    end

    a_traiter_region4 = supprimer_source(a_traiter_region4);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% interface 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%
function [imagesys, a_traiter_region4, a_traiter_region5] = traiter_interface4(imagesys, a_traiter_region4, a_traiter_region5, zinterface, alpha, beta)

z_int = zinterface(4);

%%%%%%%%%%%%%%%%%%%%% -------- région 4 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region4)
    for i = 1:length(a_traiter_region4)
        source = a_traiter_region4{i};

        if source.next_interface == 4 && ~source.deja_traite

            if source.pos(2) < z_int
                imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = -alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = (1 - alpha) * source.I;

                imagesys.addregion4(imagemirpos, imagemirI, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

                imagesys.addregion5(imagetransmispos, imagetransmisI, 5, 4);

            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / (-alpha);
                imagetransmisI = (1 - alpha) * source.I / (-alpha);

                imagesys.addregion4(imageinitialpos, imageinitialI, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};
                imagesys.addregion5(imagetransmispos, imagetransmisI, 5, 4);
            end

            a_traiter_region4{i}.deja_traite = true;
        end
    end

    a_traiter_region4 = supprimer_source(a_traiter_region4);
end

%%%%%%%%%%%%%%%%%%%%% -------- région 5 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region5)
    for i = 1:length(a_traiter_region5)
        source = a_traiter_region5{i};

        if source.next_interface == 4 && ~source.deja_traite

            if source.pos(2) > z_int
               imagemirpos = fmiry(source.pos, z_int);
                imagemirI   = alpha * source.I;

                imagetransmispos = source.pos;
                imagetransmisI   = beta * source.I;

                imagesys.addregion5(imagemirpos, imagemirI, 5, 4);
                

                imagesys.addregion4(imagetransmispos, imagetransmisI, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

            else
                imageinitialpos  = fmiry(source.pos, z_int);
                imagetransmispos = fmiry(source.pos, z_int);

                imageinitialI  = source.I / alpha;
                imagetransmisI = beta * source.I / alpha;

                imagesys.addregion5(imageinitialpos, imageinitialI, 5, 4);
                

                imagesys.addregion4(imagetransmispos, imagetransmisI, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};
            end

            a_traiter_region5{i}.deja_traite = true;
        end
    end

    a_traiter_region5 = supprimer_source(a_traiter_region5);
end

end


