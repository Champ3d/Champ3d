function rotated_node = f_rotaroundaxis(node,args)
% F_ROTAROUNDAXIS returns vector after rotation by angle a around an axis u
% given by an unit vector.
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    node                              % n x 2,3
    args.rot_axis_origin = [0 0 0];   % rot around o-->axis
    args.rot_axis   = [1 0 0];
    args.rot_angle  =  0;             % deg, counterclockwise convention
end
%--------------------------------------------------------------------------
rot_axis_origin = args.rot_axis_origin;
rot_axis   = args.rot_axis;
rot_angle  = args.rot_angle;
%--------------------------------------------------------------------------
rot_axis = rot_axis ./ norm(rot_axis);
%--------------------------------------------------------------------------
dim = size(node,1);
if dim == 2
    node = [node; zeros(1,size(node,2))];
end
%--------------------------------------------------------------------------
if length(rot_axis) == 2
    rot_axis = [rot_axis 0];
end
% ---
if length(rot_axis_origin) == 2
    rot_axis_origin = [rot_axis_origin 0];
elseif length(rot_axis_origin) == 3 && dim == 2
    rot_axis_origin(3) = [];
end
%--------------------------------------------------------------------------
if rot_angle == 0
    rotated_node = node;
    return
end
%--------------------------------------------------------------------------
rot_axis_origin = f_tocolv(rot_axis_origin);
%--------------------------------------------------------------------------
a  = rot_angle / 180 * pi;
ux = rot_axis(1);
uy = rot_axis(2);
uz = rot_axis(3);
%--------------------------------------------------------------------------
R = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) - uz*sin(a)   ux*uz*(1-cos(a)) + uy*sin(a) ; ...
     uy*ux*(1-cos(a)) + uz*sin(a)  cos(a) + uy^2 * (1-cos(a))     uy*uz*(1-cos(a)) - ux*sin(a) ;...
     uz*ux*(1-cos(a)) - uy*sin(a)  uz*uy*(1-cos(a)) + ux*sin(a)   cos(a) + uz^2 * (1-cos(a))];
%--------------------------------------------------------------------------
node = node - rot_axis_origin;
%--------------------------------------------------------------------------
rotated_node = R * node;
%--------------------------------------------------------------------------
rotated_node = rotated_node + rot_axis_origin;
%--------------------------------------------------------------------------
if dim == 2
    rotated_node = rotated_node(1:2,:);
end
%--------------------------------------------------------------------------

