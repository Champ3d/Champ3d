// ---
id_volume_list++;
// ---
center = {0, 0, 0};
bottom = {0, 0, 0};
r = 1;
hei = 1;
opening_angle = 2*Pi;
orientation = {0, 0, 1};
// ---
id_volume = newv;
Cylinder(id_volume) = {bottom(0), bottom(1), bottom(2), hei*orientation(0), hei*orientation(1), hei*orientation(2), r, opening_angle};
volume_list~{id_volume_list}() = {id_volume};
// ---