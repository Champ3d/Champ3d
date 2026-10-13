// ---
surface_center = CenterOfMass Surface{surface_list~{id_surface_list}};
destination = {x(1),y(1),z(1)};
// ---
distance = {destination(0)-surface_center(0), destination(1)-surface_center(1), destination(2)-surface_center(2)};
Translate {distance(0), distance(1), distance(2)} { Surface{surface_list~{id_surface_list}()}; }
// --- computed to fit
fit_axis = {1,0,0};
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