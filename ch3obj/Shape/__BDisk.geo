// ---
id_surface_list++;
// ---
radius = 1;
center = {0, 0, 0};
id_surface = news;
Disk(id_surface) = {center(0), center(1), center(2), radius};
surface_list~{id_surface_list}() = {id_surface};
// ---