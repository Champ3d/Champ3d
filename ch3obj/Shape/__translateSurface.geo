// ---
distance = {0, 0, 0};
nb_copy = 0;
If (nb_copy == 0)
    Translate {distance(0), distance(1), distance(2)} { Surface{surface_list~{id_surface_list}()}; }
ElseIf (nb_copy > 0)
    copy_surface_list~{id_surface_list}() = {};
    For i In {1 : nb_copy}
        copy_surface_list~{id_surface_list}() += Translate {i*distance(0), i*distance(1), i*distance(2)}
                             { Duplicata{Surface{surface_list~{id_surface_list}()};} };
    EndFor
    // Union
    surface_list~{id_surface_list}() = BooleanUnion
    { Surface{surface_list~{id_surface_list}()}; Delete; }
    { Surface{copy_surface_list~{id_surface_list}()}; Delete; };
EndIf
// ---