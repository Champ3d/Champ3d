// ---
If (use_user_defined_airbox == 1)
    // Coherence
    v() = BooleanFragments{ Volume{:}; Delete; } {};
    // ---
    id_air_dom_string = "by_default_air";
    id_air_dom_number = 3660369;
    Physical Volume(Str(id_air_dom_string), id_air_dom_number) = v(#v()-1);
    // ---
    air_mesh_size = 0;
    If (air_mesh_size > tol_mesh_size)
        MeshSize{ PointsOf{ Volume{v(#v()-1)}; } } = air_mesh_size;
    EndIf
Else
    If (use_bounding_box_airbox == 1)
        // ---
        bounding_box() = BoundingBox Volume{physical_volume_list()};
        xmin = bounding_box(0);
        ymin = bounding_box(1);
        zmin = bounding_box(2);
        xmax = bounding_box(3);
        ymax = bounding_box(4);
        zmax = bounding_box(5);
        // ---
        id_volume_list++;
        // ---
        corner = {xmin, ymin, zmin};
        len    = {xmax - xmin, ymax - ymin, zmax - zmin};
        // ---
        id_volume = newv;
        Box(id_volume) = {corner(0), corner(1), corner(2), len(0), len(1), len(2)};
        volume_list~{id_volume_list}() = {id_volume};
        // ---
        // Coherence
        v() = BooleanFragments{ Volume{:}; Delete; } {};
        // ---
        id_air_dom_string = "by_default_air";
        id_air_dom_number = 3660369;
        Physical Volume(Str(id_air_dom_string), id_air_dom_number) = v(#v()-1);
        // ---
        // air_mesh_size = 0;
        // If (air_mesh_size > tol_mesh_size)
        //    MeshSize{ PointsOf{ Volume{v(#v()-1)}; } } = air_mesh_size;
        //EndIf
    Else
        Coherence;
    EndIf
EndIf
// ---
General.NumThreads = 0;
Mesh.ElementOrder = 1;
Mesh.MeshSizeFactor = 1;
//Mesh.MeshSizeMin = 0;
//Mesh.MeshSizeMax = 1e22;
//Mesh.MeshSizeFromCurvature = 20;
Mesh.MeshSizeFromPoints = 1;
Mesh.Format = 50;
Mesh.SaveAll = 0;
//Mesh 3;
//Coherence Mesh;
//RenumberMeshNodes;
//RenumberMeshElements;