function vecout = f_rotaroundaxis(vecin,varargin)
% F_ROTAROUNDAXIS returns vector after rotation by angle a around an axis u
% given by an unit vector.
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'rot_origin','rot_axis','angle'};

% --- default input value
rot_origin = [0 0 0];
rot_axis = [1 0 0];
angle = 0; % deg

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
rot_axis = rot_axis ./ norm(rot_axis);
%--------------------------------------------------------------------------
a = angle / 180 * pi;
ux = rot_axis(1);
uy = rot_axis(2);
uz = rot_axis(3);
%--------------------------------------------------------------------------
R = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) - uz*sin(a)   ux*uz*(1-cos(a)) + uy*sin(a) ; ...
     uy*ux*(1-cos(a)) + uz*sin(a)  cos(a) + uy^2 * (1-cos(a))     uy*uz*(1-cos(a)) - ux*sin(a) ;...
     uz*ux*(1-cos(a)) - uy*sin(a)  uz*uy*(1-cos(a)) + ux*sin(a)   cos(a) + uz^2 * (1-cos(a))];
%--------------------------------------------------------------------------
vecin = vecin - rot_origin;
%--------------------------------------------------------------------------
vecout = R * vecin.';
vecout = vecout.';
%--------------------------------------------------------------------------



