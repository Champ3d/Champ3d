%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function f_showaxis(dim,view_n)
%--------------------------------------------------------------
xlabel('x (m)');
if dim >= 2
    ylabel('y (m)');
end
if dim >= 3
    zlabel('z (m)');
end
view(view_n);
axis equal; axis tight; hold on
%--------------------------------------------------------------
f_chlogo;