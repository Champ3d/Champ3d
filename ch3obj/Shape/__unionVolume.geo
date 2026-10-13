// ---
id_volume_list++;
// ---
volume_list~{id_volume_list}() = BooleanUnion
{ Volume{volume_list~{id_volume_list - 2}()}; Delete; }
{ Volume{volume_list~{id_volume_list - 1}()}; Delete; };
// ---
