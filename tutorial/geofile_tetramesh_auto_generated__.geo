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
radius = 1;
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
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "dom00";
id_dom_number = 2774937;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
center = {2,0,0};
corner = {1.5,-0.5,-1};
len = {1,1,2};
angle = 0;
// ---
id_volume = newv;
Box(id_volume) = {corner(0), corner(1), corner(2), len(0), len(1), len(2)};
volume_list~{id_volume_list}() = {id_volume};
// ---
If (Fabs(angle) > 1e-6)
    axis = {0,0,0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
EndIf
// ---


// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "dom01";
id_dom_number = 2776348;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
center = {4,0,0};
corner = {3.5,-0.5,-1};
len = {1,1,2};
angle = 0.9553166181245092;
// ---
id_volume = newv;
Box(id_volume) = {corner(0), corner(1), corner(2), len(0), len(1), len(2)};
volume_list~{id_volume_list}() = {id_volume};
// ---
If (Fabs(angle) > 1e-6)
    axis = {-1,1,0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
EndIf
// ---


// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "dom02";
id_dom_number = 2777755;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
center = {6,0,0};
rtorus = 1; 
rsection = 0.5;
opening_angle = 3.141592653589793;
angle = 1.570796326794897;
// ---
If ( (rtorus > 0) && (rsection > 0) && (rtorus >= rsection) )
    id_volume = newv;
    Torus(id_volume) = {center(0), center(1), center(2), rtorus, rsection, opening_angle};
    volume_list~{id_volume_list}() = {id_volume};
EndIf
// ---
If (angle != 0)
    axis = {0,1,0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Volume{volume_list~{id_volume_list}()}; }
EndIf
// ---


// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "dom03";
id_dom_number = 2779158;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
center = {7,0,0};
bottom = {7,-1,0};
r = 1;
hei = 2;
opening_angle = 3.141592653589793;
orientation = {0,1,0};
// ---
id_volume = newv;
Cylinder(id_volume) = {bottom(0), bottom(1), bottom(2), hei*orientation(0), hei*orientation(1), hei*orientation(2), r, opening_angle};
volume_list~{id_volume_list}() = {id_volume};
// ---


// ---
If (use_user_defined_airbox == 1)
    volume_list~{id_volume_list}() = BooleanIntersection
        { Volume{volume_list~{id_volume_list}()}; Delete; }
        { Volume{airbox_volume_list()}; };
EndIf
// ---
id_dom_string = "dom04";
id_dom_number = 2780556;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 

// ---
id_volume_list++;
// ---
center = {9,0,0};
bottom = {9,-0.5,0};
ri = 0.5;
ro = 1;
hei = 1;
opening_angle = 3.141592653589793;
orientation = {0,1,0};
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
id_dom_string = "dom05";
id_dom_number = 2781949;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.5;
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
 
