// ---
id_volume_list++;
// ---
center = {0, 0, 0};
corner = {0, 0, 0};
len    = {1, 1, 1};
angle  = 0;
// ---
id_volume = newv;
Box(id_volume) = {corner(0), corner(1), corner(2), len(0), len(1), len(2)};
volume_list~{id_volume_list}() = {id_volume};
// ---
If (angle != 0)
    axis = {0, 0, 1};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
EndIf