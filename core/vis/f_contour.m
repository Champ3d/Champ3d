%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function f_contour(args)

arguments
    args.node
    args.scalar_field
    args.nb_grid_point = 100
    args.nb_level = 50;
    args.show_level = 'on';
end

% ---
node = args.node;
sfield = args.scalar_field;
nb_grid_point = args.nb_grid_point;
nb_level = args.nb_level;
show_level = args.show_level;
% ---
dim  = size(node,1);
% ---
x = node(1,:).';
y = node(2,:).';
xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);
if dim > 2
    z = node(3,:).';
    zmin = min(z);
    zmax = max(z);
end
% ---
X = linspace(xmin,xmax,nb_grid_point);
Y = linspace(ymin,ymax,nb_grid_point);
if dim > 2
    Z = linspace(zmin,zmax,nb_grid_point);
end
% ---
if dim == 2
    F = scatteredInterpolant(x,y,sfield);
    [X,Y] = meshgrid(X,Y);
    Fval = F(X,Y);
elseif dim > 2
    F = scatteredInterpolant(x,y,z,sfield);
    [X,Y,Z] = meshgrid(X,Y,Z);
    Fval = F(X,Y,Z);
end
% ---
if dim == 2
    c = contour(X,Y,Fval,nb_level);
    if f_strcmpi(show_level,'on')
        clabel(c)
    end
    view(2);
    axis equal;
    f_colormap; colorbar;
elseif dim > 2
    c = contour3(X,Y,Z,Fval,nb_level);
    if f_strcmpi(show_level,'on')
        clabel(c)
    end
    view(3);
    axis equal;
    f_colormap; colorbar;
end

end