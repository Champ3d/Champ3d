SetFactory("OpenCASCADE");

Include "cylindreSpire_data.pro";

nSpires = 3;

// coil (linear)
rotAngle = Pi/nSpires;

np = 1;

For iz In {-1:1:2}
  For iSpire In {0:nSpires-1}
    Circle (np) = {0.0,0.0,iz*airgap/2,r_i,open_i*Pi/180};
    Circle (np+2) = {0.0,0.0,iz*airgap/2,r_o,open_o*Pi/180};
    Rotate { { 0.0,0.0,1.0 }, { 0,0,0 }, -open_i*Pi/360 } { Line{np}; }
    Rotate { { 0.0,0.0,1.0 }, { 0,0,0 }, -open_o*Pi/360 } { Line{np+2}; }
    p1 = PointsOf{ Line{np}; };
    p2 = PointsOf{ Line{np+2}; };
    Line (np+1) = {p1[1],p2[1]};
    Line (np+3) = {p2[0],p1[0]};
    Rotate { { 0.0,0.0,1.0 }, { 0,0,0 }, iSpire*2*Pi/nSpires-rotAngle } { Line{np:np+3}; }

    np += 4;

  EndFor
EndFor
  
nv = 1;

// plane
Disk(1) = {0.0,0.0,-ep_fer-d_fer-airgap/2,r_fer};
Extrude { 0.0,0.0,ep_fer } { Surface{1}; Layers{3}; Recombine; }
nv++;

ns = news;
Disk(ns) = {0.0,0.0,airgap/2+d_fer,r_fer};
Extrude { 0.0,0.0,ep_fer } { Surface{ns}; Layers{3}; Recombine; }
nv++;

// air
Cylinder(nv+1) = {0.0,0.0,-ep_fer-d_fer-airgap,0.0,0.0,2*ep_fer+2*airgap+2*d_fer,1.5*r_fer};

BooleanDifference(nv) = { Volume{nv+1}; Delete; } { Volume{1:nv-1}; };

Line{1:24} In Volume {3};

// unicity of entites
Coherence;

// physical domains
Physical Volume (1) = {1,2};// plane
Physical Volume (2) = {3};// air

// air boundary
bd = Abs[CombinedBoundary { Volume{1:nv}; }];
Physical Surface (100) = bd[];

// coil
For iSpire In {0:2*nSpires-1}
  Physical Line (1000+iSpire) = {iSpire*4+1,iSpire*4+2,-(iSpire*4+3),iSpire*4+4};
EndFor

p1 = PointsOf{ Volume{1}; };
p2 = PointsOf{ Volume{2}; };
Physical Point (2000) = {p1[0],p2[0]};

// scale = 1;

nfield = 1;

// Field[nfield] = Cylinder;
// Field[nfield].VIn = d_fer;
// Field[nfield].VOut = r_fer/5;
// Field[nfield].Radius = r_o;
// Field[nfield].ZAxis = 4*d_fer;
// Field[nfield].ZCenter = -ep_fer-d_fer-airgap/2;

// nfield++;

// Field[nfield] = Cylinder;
// Field[nfield].VIn = d_fer;
// Field[nfield].VOut = r_fer/5;
// Field[nfield].Radius = r_o;
// Field[nfield].ZAxis = 4*d_fer;
// Field[nfield].ZCenter = airgap/2;

// nfield++;

Field[nfield] = Constant ;
Field[nfield].VIn = r_fer/5;
Field[nfield].VOut = r_fer/5;
Field[nfield].SurfacesList = {1,ns};

// nfield++;

// Field[nfield] = Min;
// Field[nfield].FieldsList = {1:nfield-1};

Background Field = nfield;

//Transfinite Curve{1:48} = 10;

//Transfinite Surface{1,4};
//Recombine Surface{1,4};

//Transfinite Volume{1,2};
//Recombine Volume{1};

Mesh 3;
//RefineMesh;

Save "2cylindres2x3spires.msh";