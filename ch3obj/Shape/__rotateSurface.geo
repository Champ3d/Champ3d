// ---
origin = {0, 0, 0};
axis = {0, 0, 1};
angle = 0;
nb_copy = 0;
If ( (nb_copy == 0) && (angle != 0) )
    Rotate {{axis(0), axis(1), axis(2)}, {origin(0), origin(1), origin(2)}, angle} { Surface{surface_list~{id_surface_list}()}; }
ElseIf ( (nb_copy > 0) && (angle != 0) )
    copy_surface_list~{id_surface_list}() = {};
    For i In {1 : nb_copy}
        copy_surface_list~{id_surface_list}() += Rotate {{axis(0), axis(1), axis(2)}, {origin(0), origin(1), origin(2)}, i*angle}
                             { Duplicata{Surface{surface_list~{id_surface_list}()};} };
    EndFor
    // Union
    surface_list~{id_surface_list}() = BooleanUnion
    { Surface{surface_list~{id_surface_list}()}; Delete; }
    { Surface{copy_surface_list~{id_surface_list}()}; Delete; };
EndIf
// ---