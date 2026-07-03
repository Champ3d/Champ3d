function [imagesys, a_traiter_region2, a_traiter_region3] = traiter_interface2(imagesys, a_traiter_region2, a_traiter_region3, zinterface, alpha, beta)

zint = zinterface(2);

% -------- région 2 --------
if ~isempty(a_traiter_region2)
    for i = 1:length(a_traiter_region2)
        source = a_traiter_region2{i};

        if source.next_interface == 2 && ~source.deja_traite
           
            

            if source.coil.turn{1}.z < zint
               imagemir=source.coil';
               imagetransmis=source.coil';
               imagemir.zmirrow(zint);
               imagemir.I   = -alpha * source.coil.I;

               imagetransmis.I   = (1 - alpha) * source.coil.I;
               imagesys.addregion2(imagemir, 2, 1);
               a_traiter_region2{end+1} = imagesys.imageregion2{end};

%               imagesys.addregion3(imagetransmis, 3, 3);
%               a_traiter_region3{end+1} = imagesys.imageregion3{end};

            else

                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / (-alpha);
                imagetransmis.I = (1 - alpha) * source.coil.I / (-alpha);

                imagesys.addregion2(imageinitial, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

%                 imagesys.addregion3(imagetransmis, 3, 3);
%                 a_traiter_region3{end+1} = imagesys.imageregion3{end};
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

            if source.coil.turn{1}.z > zint
                imagemir=source.coil';
                
                imagemir.zmirrow(zint);
                imagemir.I   = alpha * source.coil.I;

                 imagetransmis=source.coil';
                 imagetransmis.I   = beta * source.coil.I;

                imagesys.addregion3(imagemir, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion2(imagetransmis, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / alpha;
                imagetransmis.I = beta * source.coil.I / alpha;

                imagesys.addregion3(imageinitial, 3, 3);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion2(imagetransmis, 2, 1);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
            end

            a_traiter_region3{i}.deja_traite = true;
        end
    end
    a_traiter_region3 = supprimer_source(a_traiter_region3);
end

end
