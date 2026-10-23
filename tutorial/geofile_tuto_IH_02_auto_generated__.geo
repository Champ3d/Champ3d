// --- Init
SetFactory("OpenCASCADE");
id_point_list = 0;
id_curve_list = 0;
id_curve_loop_list = 0;
id_surface_list = 0;
id_surface_loop_list = 0;
id_volume_list = 0;
physical_volume_list = {};
use_user_defined_airbox = 1;
use_bounding_box_airbox = 0;
tol_mesh_size = 1e-09;
// ---
 

// --- airbox

// ---
id_volume_list++;
// ---
center = {0,0,0};
corner = {-0.06,-0.06,-0.06};
len = {0.12,0.12,0.12};
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
    airbox_volume_list() = {id_volume};
EndIf
// ---



 

// ---
id_volume_list++;
// ---
center = {0,0,0};
corner = {-0.005,-0.03,-0.005};
len = {0.01,0.06,0.01};
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
distance = {0,0,0.015};
nb_copy = 1;
If (nb_copy == 1)
    Translate {distance(0), distance(1), distance(2)} { Volume{volume_list~{id_volume_list}()}; }
ElseIf (nb_copy > 1)
    copy_volume_list~{id_volume_list}() = {};
    For i In {1 : nb_copy-1}
        copy_volume_list~{id_volume_list}() += Translate {i*distance(0), i*distance(1), i*distance(2)}
                             { Duplicata{Volume{volume_list~{id_volume_list}()};} };
    EndFor
    // Union
    volume_list~{id_volume_list}() = BooleanUnion
    { Volume{volume_list~{id_volume_list}()}; Delete; }
    { Volume{copy_volume_list~{id_volume_list}()}; Delete; };
EndIf
// ---


// ---
id_volume_list++;
// ---
center = {0,-0.025,0};
corner = {-0.005,-0.03,-0.005};
len = {0.01,0.01,0.01};
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
distance = {0,0,0.005};
nb_copy = 1;
If (nb_copy == 1)
    Translate {distance(0), distance(1), distance(2)} { Volume{volume_list~{id_volume_list}()}; }
ElseIf (nb_copy > 1)
    copy_volume_list~{id_volume_list}() = {};
    For i In {1 : nb_copy-1}
        copy_volume_list~{id_volume_list}() += Translate {i*distance(0), i*distance(1), i*distance(2)}
                             { Duplicata{Volume{volume_list~{id_volume_list}()};} };
    EndFor
    // Union
    volume_list~{id_volume_list}() = BooleanUnion
    { Volume{volume_list~{id_volume_list}()}; Delete; }
    { Volume{copy_volume_list~{id_volume_list}()}; Delete; };
EndIf
// ---

// ---
distance = {0,0.025,0};
nb_copy = 3;
If (nb_copy == 1)
    Translate {distance(0), distance(1), distance(2)} { Volume{volume_list~{id_volume_list}()}; }
ElseIf (nb_copy > 1)
    copy_volume_list~{id_volume_list}() = {};
    For i In {1 : nb_copy-1}
        copy_volume_list~{id_volume_list}() += Translate {i*distance(0), i*distance(1), i*distance(2)}
                             { Duplicata{Volume{volume_list~{id_volume_list}()};} };
    EndFor
    // Union
    volume_list~{id_volume_list}() = BooleanUnion
    { Volume{volume_list~{id_volume_list}()}; Delete; }
    { Volume{copy_volume_list~{id_volume_list}()}; Delete; };
EndIf
// ---

// ---
id_volume_list++;
// ---
volume_list~{id_volume_list}() = BooleanUnion
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
id_dom_string = "fer";
id_dom_number = 2620837;
Physical Volume(Str(id_dom_string), id_dom_number) = {volume_list~{id_volume_list}()};
physical_volume_list += {volume_list~{id_volume_list}()};
// ---
mesh_size = 0.002;
If (mesh_size > tol_mesh_size)
    MeshSize{ PointsOf{ Volume{volume_list~{id_volume_list}()}; } } = mesh_size;
EndIf
// ---


 


// ---
id_point_list++;
id_curve_list++;
id_curve_loop_list++;
// ---
x = {0.025,0.025,0.025,0.025,0.025,0.02,0.01375,0.0075,0.001249999999999998,-0.004999999999999998,-0.01205342302750968,-0.01641267819554184,-0.01641267819554184,-0.01205342302750968,-0.004999999999999998,0.001249999999999998,0.007499999999999996,0.01375,0.02,0.025,0.025,0.025,0.025,0.025};
y = {-0.012,-0.012,-0.012,-0.012,-0.012,-0.012,-0.012,-0.012,-0.012,-0.012,-0.00970820393249937,-0.00370820393249937,0.00370820393249937,0.009708203932499371,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012,0.012};
z = {0.105,0.08125,0.0575,0.03375,0.01000000000000001,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.005000000000000004,0.01000000000000001,0.03375,0.0575,0.08125000000000002,0.105};
type = 0; // 0-open, 1-closed
// ---
id_point = newp;
nb_point = #x();
nb_curve = nb_point - 1;
point_list~{id_point_list}() = {};
For i In {0 : nb_point-1}
  Point(id_point + i) = {x(i), y(i), z(i)};
  point_list~{id_point_list}() += id_point + i;
EndFor
If (type == 1)
  point_list~{id_point_list}() += id_point;
EndIf
// ---
id_curve = newl;
BSpline(id_curve) = {point_list~{id_point_list}()};
curve_list~{id_curve_list}() = {id_curve};
// ---
id_curve_loop = newcl;
Wire(id_curve_loop) = {id_curve};
curve_loop_list~{id_curve_loop_list}() = {id_curve_loop};
// ---


// ---
id_surface_list++;
// ---
center = {0,0,0};
corner = {-0.0025,-0.005,0};
len = {0.005,0.01};
r_corner = 0.001;
angle = 0;
// ---
id_surface = news;
Rectangle(id_surface) = {corner(0), corner(1), corner(2), len(0), len(1), r_corner};
surface_list~{id_surface_list}() = {id_surface};
// ---
If (Fabs(angle) > 1e-6)
    axis = {0,0,0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Surface{surface_list~{id_surface_list}()}; }
EndIf
// ---


// ---
id_surface_list++;
// ---
center = {0,0,0};
corner = {-0.00125,-0.0025,0};
len = {0.0025,0.005};
r_corner = 0.0005;
angle = 0;
// ---
id_surface = news;
Rectangle(id_surface) = {corner(0), corner(1), corner(2), len(0), len(1), r_corner};
surface_list~{id_surface_list}() = {id_surface};
// ---
If (Fabs(angle) > 1e-6)
    axis = {0,0,0};
    Rotate {{axis(0), axis(1), axis(2)}, {center(0), center(1), center(2)}, angle} { Surface{surface_list~{id_surface_list}()}; }
EndIf
// ---

// ---
id_surface_list++;
// ---
surface_list~{id_surface_list}() = BooleanDifference
{ Surface{surface_list~{id_surface_list - 2}()}; Delete; }
{ Surface{surface_list~{id_surface_list - 1}()}; Delete; };
// ---




// ---
surface_center = CenterOfMass Surface{surface_list~{id_surface_list}};
destination = {x(1),y(1),z(1)};
// ---
distance = {destination(0)-surface_center(0), destination(1)-surface_center(1), destination(2)-surface_center(2)};
Translate {distance(0), distance(1), distance(2)} { Surface{surface_list~{id_surface_list}()}; }
// --- computed to fit
fit_axis = {0,0,1};
fit_angle = 0;
// ---
If (Fabs(fit_angle) > 1e-6)
    Rotate {{fit_axis(0), fit_axis(1), fit_axis(2)}, {destination(0), destination(1), destination(2)}, fit_angle} { Surface{surface_list~{id_surface_list}()}; }
EndIf
// --- choice
rotation = 0;
curve_axis = {x(2)-x(1), y(2)-y(1), z(2)-z(1)};
// ---
If (Fabs(rotation) > 1e-6)
    Rotate {{curve_axis(0), curve_axis(1), curve_axis(2)}, {destination(0), destination(1), destination(2)}, rotation} { Surface{surface_list~{id_surface_list}()}; }
EndIf
// ---
id_volume = newv;
volume_list~{id_volume_list}() = Extrude { Surface{surface_list~{id_surface_list}}; } Using Wire {curve_loop_list~{id_curve_loop_list}};
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
mesh_size = 0.001;
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
    id_air_dom_string = "air";
    id_air_dom_number = 2620322;
    Physical Volume(Str(id_air_dom_string), id_air_dom_number) = {airbox_volume_list()};
    // ---
    /*
    air_mesh_size = 0.005;
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
        id_air_dom_string = "air";
        id_air_dom_number = 2620322;
        Physical Volume(Str(id_air_dom_string), id_air_dom_number) = {airbox_volume_list()};
        // ---
        // air_mesh_size = 0.005;
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
 
