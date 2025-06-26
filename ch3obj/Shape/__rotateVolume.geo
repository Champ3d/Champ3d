// ---
origin = {0, 0, 0};
axis = {0, 0, 1};
angle = 0;
nb_copy = 0;
If ( (nb_copy == 0) && (angle != 0) )
    Rotate {{axis(0), axis(1), axis(2)}, {origin(0), origin(1), origin(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
ElseIf ( (nb_copy > 0) && (angle != 0) )
    copy_volume_list~{id_volume_list}() = {};
    For i In {1 : nb_copy}
        copy_volume_list~{id_volume_list}() += Rotate {{axis(0), axis(1), axis(2)}, {origin(0), origin(1), origin(2)}, i*angle}
                             { Duplicata{Volume{volume_list~{id_volume_list}()};} };
    EndFor
    // Union
    volume_list~{id_volume_list}() = BooleanUnion
    { Volume{volume_list~{id_volume_list}()}; Delete; }
    { Volume{copy_volume_list~{id_volume_list}()}; Delete; };
EndIf
// ---