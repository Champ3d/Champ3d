// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "id";
id_dom_number = 1;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---
