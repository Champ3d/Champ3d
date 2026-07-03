function [imagesys, a_traiter_region4, a_traiter_region5] = traiter_interface4(imagesys, a_traiter_region4, a_traiter_region5, zinterface, alpha, beta)

zint = zinterface(4);

%%%%%%%%%%%%%%%%%%%%% -------- région 4 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region4)
    for i = 1:length(a_traiter_region4)
        source = a_traiter_region4{i};

        if source.next_interface == 4 && ~source.deja_traite

            if source.coil.turn{1}.z < zint
                imagemir=source.coil';
                imagemir.zmirrow(zint);

                imagemir.I= -alpha * source.coil.I;

                imagetransmis=source.coil';
                imagetransmis.I   = (1 - alpha) * source.coil.I;

                imagesys.addregion4(imagemir, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

                imagesys.addregion5(imagetransmis, 5, 4);

            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / (-alpha);
                imagetransmis.I = (1 - alpha) * source.coil.I / (-alpha);

                imagesys.addregion4(imageinitial, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};
                imagesys.addregion5(imagetransmis, 5, 4);
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

            if source.coil.turn{1}.z > zint
                imagemir=source.coil';
                imagemir.zmirrow(zint);
                imagemir.I   = alpha * source.coil.I;

                 imagetransmis=source.coil';
                imagetransmis.I   = beta * source.coil.I;

                imagesys.addregion5(imagemir, 5, 4);
                

                imagesys.addregion4(imagetransmis, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / alpha;
                imagetransmis.I = beta * source.coil.I / alpha;

                imagesys.addregion5(imageinitial, 5, 4);
                

                imagesys.addregion4(imagetransmis, 4, 3);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};
            end

            a_traiter_region5{i}.deja_traite = true;
        end
    end

    a_traiter_region5 = supprimer_source(a_traiter_region5);
end

end