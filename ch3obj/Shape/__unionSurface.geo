// ---
id_surface_list++;
// ---
surface_list~{id_surface_list}() = BooleanUnion
{ Surface{surface_list~{id_surface_list - 2}()}; Delete; }
{ Surface{surface_list~{id_surface_list - 1}()}; Delete; };
// ---
