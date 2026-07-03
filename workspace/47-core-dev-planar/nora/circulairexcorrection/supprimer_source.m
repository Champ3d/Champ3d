function liste_out = supprimer_source(liste_in)
arguments
    liste_in cell = {}
end

liste_out = {};

for i = 1:numel(liste_in)
    source = liste_in{i};

    if ~source.deja_traite
        liste_out{end+1} = source;
    end
end
end