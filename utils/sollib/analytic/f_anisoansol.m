function result = f_anisoansol(varargin)
% F_ANISOANSOL compute impedance variation of a circular coil horizontally 
% parallel to a finite thickness anisotropic plate.
%--------------------------------------------------------------------------
% result = F_ANISOANSOL();
%
% sigma =[sigma_x         0          0; --- conductivity tensor
%         0         sigma_y          0;
%         0               0    sigma_y];
%--------------------------------------------------------------------------
% Reference : Burke, S. K. (1990). Eddy?current induction in a uniaxially 
% anisotropic plate. Journal of applied physics, 68(7), 3080-3090.
% "The model assumes that the plate is nonmagnetic and that the axis of 
% uniaxial anisotropy is horizontal (i.e., lying in a plane
% parallel to the surface of the plate)."
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


for i = 1 : nargin/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i};']);
end

%-------------------- Constants -------------------------------------------
mu0=4*pi*1e-7;

%-------------------- Integration parameters ------------------------------

if ~exist('delta_lambda','var')
    delta_lambda = 0.01; % 0.1
end
if ~exist('delta_alpha','var')
    delta_alpha  = 10;   % 20
end
if ~exist('min_alpha','var')
    min_alpha = 0.1;
end
if ~exist('max_alpha','var')
    max_alpha = 1000;
end


%-------------------- 2 skin depths ---------------------------------------
omega = 2*pi*fr;
result.skdepth_x   = sqrt(2/(omega*sigma_x*mu0));
result.skdepth_y   = sqrt(2/(omega*sigma_y*mu0));

%-------------------- equations 26abc, 27 ---------------------------------

kx = sqrt(1j*omega*sigma_x*mu0);
ky = sqrt(1j*omega*sigma_y*mu0);

t = coil_hei/2;
d = airgap + t;
n = nb_turn/(2*t*(coil_rex-coil_rin));

%-------------------- impedance variation ---------------------------------
delta_Z = 0;
for alp = min_alpha : delta_alpha : max_alpha
    Beta      = sqrt(alp^2+ky^2);
    P_R_Alpha = 0;
    for lambda = 0 : delta_lambda : 2*pi
        u     = alp*cos(lambda);
        v     = alp*sin(lambda);
        Gamma = sqrt(u^2*sigma_x/sigma_y+v^2+kx^2);
        P     = alp*Gamma*(ky^2+u^2);
        Qplus = (ky^2)*(v^2)+Beta*Gamma*u^2;
        Qmoin = (ky^2)*(v^2)-Beta*Gamma*u^2;
        Delta = (P^2+Qplus^2)*(cosh((Beta+Gamma)*plate_thickness)-1)- ...
                (P^2+Qmoin^2)*(cosh((Beta-Gamma)*plate_thickness)-1)+ ...
                 2*P*Qmoin*sinh((Beta-Gamma)*plate_thickness)+...
                 2*P*Qplus*sinh((Beta+Gamma)*plate_thickness);
        R = (Qplus^2-P^2)*(cosh((Beta+Gamma)*plate_thickness)-1)/Delta+...
            (P^2-Qmoin^2)*(cosh((Beta-Gamma)*plate_thickness)-1)/Delta;
        P_R_Alpha = P_R_Alpha+R*delta_lambda;
    end

    F1 = @(x)x.*besselj(1,x);
    Jbessel = integral(F1,alp*coil_rin,alp*coil_rex);
    
    Integ_Z = (exp(-2*alp*d)/(alp^6))*((sinh(alp*t))^2)*(Jbessel^2)*P_R_Alpha;
    % impedance variation
    delta_Z = delta_Z + 2j*omega*mu0*(n^2)*Integ_Z*delta_alpha;
end

result.delta_R = real(delta_Z);
result.delta_X = imag(delta_Z);



