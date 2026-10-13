// ---
id_volume_list++;
// ---
center = {0, 0, 0};
bottom = {0, 0, 0};
ri = 1;
ro = 2;
hei = 1;
opening_angle = 2*Pi;
orientation = {0, 0, 1};
// ---
id_volume_i = newv;
Cylinder(id_volume_i) = {bottom(0), bottom(1), bottom(2), hei*orientation(0), hei*orientation(1), hei*orientation(2), ri, opening_angle};
id_volume_o = newv;
Cylinder(id_volume_o) = {bottom(0), bottom(1), bottom(2), hei*orientation(0), hei*orientation(1), hei*orientation(2), ro, opening_angle};
// ---
volume_list~{id_volume_list}() = BooleanDifference
{ Volume{id_volume_o}; Delete; }
{ Volume{id_volume_i}; Delete; };
// ---