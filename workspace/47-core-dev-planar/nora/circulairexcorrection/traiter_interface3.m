
function [imagesys, a_traiter_region3, a_traiter_region4] = traiter_interface3(imagesys, a_traiter_region3, a_traiter_region4, zinterface, alpha, beta)

   zint = zinterface(3);

%%%%%%%%%%%%%%%%%%%%% -------- région 3 -------- %%%%%%%%%%%%%%%%%%%%%
if ~isempty(a_traiter_region3)
    for i = 1:length(a_traiter_region3)
        source = a_traiter_region3{i};

        if source.next_interface == 3 && ~source.deja_traite

            if source.coil.turn{1}.z < zint
                imagemir=source.coil';
                imagemir.zmirrow(zint);
                imagemir.I   = alpha * source.coil.I;

                imagetransmis=source.coil';
                imagetransmis.I   = beta * source.coil.I;

                imagesys.addregion3(imagemir, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion4(imagetransmis, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / alpha;
                imagetransmis.I = beta * source.coil.I / alpha;

                imagesys.addregion3(imageinitial, 3, 2);
                a_traiter_region3{end+1} = imagesys.imageregion3{end};

                imagesys.addregion4(imagetransmis, 4, 4);
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

            if source.coil.turn{1}.z > zint
                 imagemir=source.coil';
                 imagemir.zmirrow(zint);
                imagemir.I   = -alpha * source.coil.I;

                imagetransmis=source.coil';
                imagetransmis.I   = (1 - alpha) * source.coil.I;

                imagesys.addregion4(imagemir, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

%                 imagesys.addregion3(imagetransmis, 3, 2);
%                 a_traiter_region3{end+1} = imagesys.imageregion3{end};


            else
                imageinitial=source.coil';
                imagetransmis=source.coil';
                imageinitial.zmirrow(zint);
                imagetransmis.zmirrow(zint);

                imageinitial.I  = source.coil.I / (-alpha);
                imagetransmis.I = (1 - alpha) * source.coil.I / (-alpha);

                imagesys.addregion4(imageinitial, 4, 4);
                a_traiter_region4{end+1} = imagesys.imageregion4{end};

%                 imagesys.addregion3(imagetransmis, 3, 2);
%                 a_traiter_region3{end+1} = imagesys.imageregion3{end};
            end

            a_traiter_region4{i}.deja_traite = true;
        end
    end

    a_traiter_region4 = supprimer_source(a_traiter_region4);
end

end
