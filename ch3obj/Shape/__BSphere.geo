// ---
id_volume_list++;
// ---
radius = 1;
center = {0, 0, 0};
opening_angle_1 = -Pi/2;
opening_angle_2 = +Pi/2;
opening_angle_3 = 2*Pi;
// ---
id_volume = newv;
Sphere(id_volume) = {center(0), center(1), center(2), radius, opening_angle_1, opening_angle_2, opening_angle_3};
volume_list~{id_volume_list}() = {id_volume};
// ---