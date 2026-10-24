// --- Init
SetFactory("OpenCASCADE");
id_point_list = 0;
id_curve_list = 0;
id_curve_loop_list = 0;
id_surface_list = 0;
id_surface_loop_list = 0;
id_volume_list = 0;
physical_volume_list = {};
use_user_defined_airbox = 0;
use_bounding_box_airbox = 0;
tol_mesh_size = 1e-09;
// ---
 

// ---
id_volume_list++;
// ---
center = {0,0,0};
bottom = {0,0,-0.001};
ri = 0.002;
ro = 0.004;
hei = 0.002;
opening_angle = 6.283185307179586;
orientation = {0,0,1};
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


// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "coil";
id_dom_number = 2776208;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.0004;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
radius = 0.04;
center = {0,0,0};
opening_angle_1 = -1.570796326794897;
opening_angle_2 = 1.570796326794897;
opening_angle_3 = 6.283185307179586;
// ---
id_volume = newv;
Sphere(id_volume) = {center(0), center(1), center(2), radius, opening_angle_1, opening_angle_2, opening_angle_3};
volume_list~{id_volume_list}() = {id_volume};
// ---


// ---
id_volume_list++;
// ---
center = {0,0,0};
bottom = {0,0,-0.001};
ri = 0.002;
ro = 0.004;
hei = 0.002;
opening_angle = 6.283185307179586;
orientation = {0,0,1};
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

// ---
id_volume_list++;
// ---
volume_list~{id_volume_list}() = BooleanDifference
{ Volume{volume_list~{id_volume_list - 2}()}; Delete; }
{ Volume{volume_list~{id_volume_list - 1}()}; Delete; };
// ---




// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "air";
id_dom_number = 2620322;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
If (use_user_defined_airbox == 1)
    // ---
    v() = BooleanFragments{ Volume{:}; Delete; } {};
    // ---
    airbox_volume_list() = {};
    For i In {0 : #v()-1}
        get_i = 1;
        For j In {0 : #physical_volume_list()-1}
            If (v(i) == physical_volume_list(j))
                get_i = 0;
            EndIf
        EndFor
        If (get_i == 1)
            airbox_volume_list += v(i);
        EndIf
    EndFor
    id_air_dom_string = "by_default_air";
    id_air_dom_number = 1;
    Physical Volume(Str(id_air_dom_string), id_air_dom_number) = {airbox_volume_list()};
    // ---
    /*
    air_mesh_size = 0;
    If (air_mesh_size > tol_mesh_size)
        MeshSize{ PointsOf{ Volume{airbox_volume_list()}; } } = air_mesh_size;
    EndIf
    */
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
        airbox_volume_list() = {};
        For i In {0 : #v()-1}
            get_i = 1;
            For j In {0 : #physical_volume_list()-1}
                If (v(i) == physical_volume_list(j))
                    get_i = 0;
                EndIf
            EndFor
            If (get_i == 1)
                airbox_volume_list += v(i);
            EndIf
        EndFor
        id_air_dom_string = "by_default_air";
        id_air_dom_number = 1;
        Physical Volume(Str(id_air_dom_string), id_air_dom_number) = {airbox_volume_list()};
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
 
