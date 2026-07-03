function liste_a_faire = extraire_nouveaux(liste_source, liste_deja,liste_a_faire , tol)
arguments
    liste_source cell={}
    liste_deja cell={}
    liste_a_faire cell={}
    tol double = 1e-10
end



for i = 1:numel(liste_source)
    elem = liste_source{i};
    existe = false;

    for j = 1:numel(liste_deja)
        samePos = norm(liste_deja{j}.pos - elem.pos) < tol;
        sameI   = abs(liste_deja{j}.I - elem.I) < tol;
        if samePos && sameI
            existe = true;
            break
        end
    end

    if ~existe
        liste_a_faire{end+1} = elem;
    end
end
end