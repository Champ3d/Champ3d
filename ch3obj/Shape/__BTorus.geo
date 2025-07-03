// ---
id_volume_list++;
// ---
center = {0, 0, 0};
rtorus = 2; 
rsection = 1;
opening_angle = 2*Pi;
angle = 0;
// ---
If ( (rtorus > 0) && (rsection > 0) && (rtorus >= rsection) )
    id_volume = newv;
    Torus(id_volume) = {center(0), center(1), center(2), rtorus, rsection, opening_angle};
    volume_list~{id_volume_list}() = {id_volume};
EndIf
// ---
If (angle != 0)
    axis = {0, 0, 1};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
EndIf
// ---