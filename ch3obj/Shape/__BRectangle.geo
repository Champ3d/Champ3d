// ---
id_surface_list++;
// ---
center = {0, 0, 0};
corner = {0, 0, 0};
len    = {1, 1};
r_corner = 0;
angle  = 0;
// ---
id_surface = news;
Rectangle(id_surface) = {corner(0), corner(1), corner(2), len(0), len(1), r_corner};
surface_list~{id_surface_list}() = {id_surface};
// ---
If (Fabs(angle) > 1e-6)
    axis = {1, 0, 0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Surface{surface_list~{id_surface_list}()}; }
EndIf
// ---