// ---
id_point_list++;
id_curve_list++;
id_curve_loop_list++;
// ---
x = {0,1};
y = {0,1};
z = {0,1};
type = "open";
// ---
id_point = newp;
nb_point = #x();
nb_curve = nb_point - 1;
point_list~{id_point_list}() = {};
For i In {0 : nb_point-1}
  Point(id_point + i) = {x(i), y(i), z(i)};
  point_list~{id_point_list}() += id_point + i;
EndFor
If (StrCmp(Str(type),Str("closed")))
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