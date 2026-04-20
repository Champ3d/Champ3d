function [imagesys, a_traiter_region1, a_traiter_region2] = traiter_interface1(imagesys, a_traiter_region1, a_traiter_region2, zinterface, alpha, beta)

zint = zinterface(1);

%%%%%%%%%%%%%%%%%%%%% -------- région 1 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region1)
    for i = 1:length(a_traiter_region1)
        source = a_traiter_region1{i};

        if source.next_interface == 1 && ~source.deja_traite

            if source.coil.turn{1}.z < zint

                imagemir=source.coil';
                imagemir.zmirrow(zint);
                imagemir.I   = alpha * source.coil.I;

                imagetransmis=source.coil';
                imagetransmis.I   = beta * source.coil.I;

                imagesys.addregion1(imagemir, 1, 1);
                

                imagesys.addregion2(imagetransmis, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / alpha;
                imagetransmis.I = beta * source.coil.I / alpha;

                imagesys.addregion1(imageinitial, 1, 1);
                

                imagesys.addregion2(imagetransmis, 2, 2);
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

            if source.coil.turn{1}.z > zint
                 imagemir=source.coil';
                 imagemir.zmirrow(zint);
                imagemir.I   = -alpha * source.coil.I;

                imagetransmis=source.coil';
                imagetransmis.I   = (1 - alpha) * source.coil.I;

                imagesys.addregion2(imagemir, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};

                imagesys.addregion1(imagetransmis, 1, 1);
               
            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / (-alpha);
                imagetransmis.I = (1 - alpha) * source.coil.I / (-alpha);

                imagesys.addregion2(imageinitial, 2, 2);
                a_traiter_region2{end+1} = imagesys.imageregion2{end};
                imagesys.addregion1(imagetransmis, 1, 1);
         
            end

            a_traiter_region2{i}.deja_traite = true;
        end
    end

    a_traiter_region2 = supprimer_source(a_traiter_region2);
end

end
