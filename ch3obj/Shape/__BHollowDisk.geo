// ---
id_surface_list++;
// ---
ri = 1;
ro = 2;
center = {0, 0, 0};
// ---
id_surface_i = news;
Disk(id_surface_i) = {center(0), center(1), center(2), ri};
id_surface_o = news;
Disk(id_surface_o) = {center(0), center(1), center(2), ro};
// ---
surface_list~{id_surface_list}() = BooleanDifference
{ Surface{id_surface_o}; Delete; }
{ Surface{id_surface_i}; Delete; };
// ---