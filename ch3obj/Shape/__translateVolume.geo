// ---
distance = {0, 0, 0};
nb_copy = 0;
If (nb_copy == 0)
    Translate {distance(0), distance(1), distance(2)} { Volume{volume_list~{id_volume_list}()}; }
ElseIf (nb_copy > 0)
    copy_volume_list~{id_volume_list}() = {};
    For i In {1 : nb_copy}
        copy_volume_list~{id_volume_list}() += Translate {i*distance(0), i*distance(1), i*distance(2)}
                             { Duplicata{Volume{volume_list~{id_volume_list}()};} };
    EndFor
    // Union
    volume_list~{id_volume_list}() = BooleanUnion
    { Volume{volume_list~{id_volume_list}()}; Delete; }
    { Volume{copy_volume_list~{id_volume_list}()}; Delete; };
EndIf
// ---