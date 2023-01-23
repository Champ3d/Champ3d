function result = f_isoansol(varargin)
% F_ISOANSOL compute eddy-current and induced power in two plates of 
% different isotropic electrical conductivities (the upper plate with finite
% thickness, the lower with infinite thickness) submitted to the excitation
% of a circular coil placed horizontally parallel to the plate.
%--------------------------------------------------------------------------
% result = F_ISOANSOL('problem','Dodd_Deeds',...
%                     'coil_rin',10e-3,'coil_rex',40e-3,'coil_hei',10e-3,...
%                     'airgap',2e-3,'plates_length',150e-3,...
%                     'top_plate_thickness',10e-3,...
%                     'bottom_plate_thickness',10e-3,...
%                     'top_plate_sigma',1e7,...
%                     'bottom_plate_sigma',1e6,...
%                     'j_coil',1e6,'fr',1e6,...
%                     'out_field',{'top_plate','bottom_plate'});
% result = F_ISOANSOL('problem','Cylinder_Conductor',...
%                     'sigma',1e7,'r_conductor',10e-3,'i_conductor',100,...
%                     'fr',20e3);
%--------------------------------------------------------------------------
% PARAMETERS LIST FOR #Dodd_Deeds:
% coil_rin
% coil_rex
% coil_hei
% airgap
% plates_length
% top_plate_thickness
% bottom_plate_thickness
% top_plate_sigma
% bottom_plate_sigma
% i_coil
% j_coil
% fr
% out_field
% delta_alpha
% min_alpha
% max_alpha
% nb_point_x
% nb_point_z
%--------------------------------------------------------------------------
% PARAMETERS LIST FOR #Cylinder_Conductor:
%--------------------------------------------------------------------------
% References:
% [1] C.V.Dodd & W.E.Deeds, Analytical Solutions to Eddy-Current 
% Probe-Coil Problems, Journal of Applied Physics, volume 39, No. 6,
% May 1968, pp. 2829?2838
% [2] Ramo, S., Whinnery, J. R. and Duzer, T. V. (1994).
% Fields and waves in communication electronics. John Wiley & sons,
% 3th edition.
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

problem = []; 

%---------------------------For Dodd & Deeds-------------------------------
coil_rin = [];
coil_rex = [];
coil_hei = [];
airgap = [];
plates_length = [];
top_plate_thickness = [];
bottom_plate_thickness = [];
top_plate_sigma = [];
bottom_plate_sigma = [];
top_plate_mur = 1;
bottom_plate_mur = 1;
i_coil = [];
j_coil = [];
fr = [];
out_field = [];
delta_alpha  = [];
min_alpha = [];
max_alpha = [];
nb_point_x = [];
nb_point_z = [];

%---------------------------For Cylinder Conductor-------------------------
sigma = [];
r_conductor  = [];    % Radius of the cylinder
i_conductor  = [];    % Current through the conductor
fr = [];
nb_point_r   = 200;
%--------------------------------------------------------------------------

for i = 1 : nargin/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i};']);
end

if isempty(problem)
    disp([mfilename ' : #problem = #Dodd_Deeds, #Cylinder_Conductor'])
end

switch lower(problem)
    % ---------------------------------------------------------------------
    case 'dodd_deeds'
        half_plates_length = plates_length/2;
        %--------------------------------Output----------------------------
        if isempty(bottom_plate_sigma)
            bottom_plate_sigma = 1e-5;
        end
        if isempty(bottom_plate_thickness)
            bottom_plate_thickness = top_plate_thickness;
        end

        %------------------------------------------------------------------
        if ~isempty(i_coil)
            j_coil = i_coil / ((coil_rex-coil_rin) * coil_hei);
        elseif isempty(j_coil)
            disp([mfilename ' : Result for j_coil = 1 A/m2']);
            j_coil = 1;
        end
        %------------------------Spacial display---------------------------
        if isempty(nb_point_x)
            nb_point_x = 101;
        end
        if isempty(nb_point_z)
            nb_point_z = 21;
        end
        %--------------------------------Output----------------------------
        if isempty(out_field)
            out_field = 'top_plate';
        end
        %-------------------- Constants -----------------------------------
        mu0 = 4*pi*1e-7;

        %-------------------- Integration parameters ----------------------
        if isempty(delta_alpha)
            delta_alpha  = 1;
        end
        if isempty(min_alpha)
            min_alpha = 0.1;
        end
        if isempty(max_alpha)
            max_alpha = 3000;
        end


        % -------- Geometry + Physical properties, Fig.3, p.2835 ----------

        r1 = coil_rin;
        r2 = coil_rex;
        l1 = airgap;
        l2 = l1 + coil_hei;
        c  = top_plate_thickness;
        omega = 2*pi*fr;
        sig_1 = top_plate_sigma;
        sig_2 = bottom_plate_sigma;
        mu = mu0;
        i0 = j_coil;

        % -----------------------------------------------------------------
        result.top_plate.skdepth = sqrt(2/(omega*sig_1*mu));
        result.bottom_plate.skdepth = sqrt(2/(omega*sig_2*mu));

        % ----------------- equation (74), p.2835 -------------------------
        % A-potentiel on the top plate

        x = +linspace(0,half_plates_length,nb_point_x);
        z = -linspace(0,top_plate_thickness,nb_point_z);
        [x, z] = meshgrid(x,z);


        A = zeros(nb_point_z,nb_point_x);
        for alp = min_alpha : delta_alpha : max_alpha
            integ = int_top_plate_eq74(alp,r1,r2,mu,sig_1,sig_2,x,l1,l2,c,z,omega);
            A = integ.*delta_alpha + A;
        end

        result.top_plate.x = x;
        result.top_plate.z = z;
        result.top_plate.A = mu*i0*A;
        result.top_plate.J = -1j*omega*sig_1 * result.top_plate.A;
        delta_s = half_plates_length/(nb_point_x-1) * top_plate_thickness/(nb_point_z-1);
        result.top_plate.P = sum(delta_s * sig_1 * abs(result.top_plate.J).^2);

        result.top_plate.J_top = result.top_plate.J(z(:,1) == 0,:);
        result.top_plate.J_mid = result.top_plate.J(z(:,1) == -c/2,:);
        result.top_plate.J_bot = result.top_plate.J(z(:,1) == -c,:);
        result.top_plate.Ox = x(1,:);

        result.top_plate.J_cen = result.top_plate.J(:,x(1,:) == 0);
        result.top_plate.Oz = z(:,1);


        % ----------------- equation (75), p.2835 -------------------------
        % A-potentiel on the bottom plate

        if any(strcmpi(out_field,'bottom_plate'))

            x = linspace(0,half_plates_length,nb_point_x);
            z = - top_plate_thickness ...
                - linspace(0,bottom_plate_thickness,nb_point_z);

            [x, z] = meshgrid(x,z);

            A = zeros(nb_point_z,nb_point_x);

            for alp = min_alpha : delta_alpha : max_alpha
                integ = int_bottom_plate_eq75(alp,r1,r2,mu,sig_1,sig_2,x,l1,l2,c,z,omega);
                A = integ.*delta_alpha + A;
            end

            result.bottom_plate.x = x;
            result.bottom_plate.z = z;
            result.bottom_plate.A = mu*i0*A;
            result.bottom_plate.J = -1j*omega*sig_1 * result.top_plate.A;
            delta_s = half_plates_length/(nb_point_x-1) * bottom_plate_thickness/(nb_point_z-1);
            result.bottom_plate.P = sum(delta_s * sig_1 * abs(result.bottom_plate.J).^2);

            result.bottom_plate.J_top = result.bottom_plate.J(z(:,1) == -c-0,:);
            result.bottom_plate.J_mid = result.bottom_plate.J(z(:,1) == -c-bottom_plate_thickness/2,:);
            result.bottom_plate.J_bot = result.bottom_plate.J(z(:,1) == -c-bottom_plate_thickness,:);
            result.bottom_plate.Ox = x(1,:);

            result.bottom_plate.J_cen = result.bottom_plate.J(:,x(1,:) == 0);
            result.bottom_plate.Oz = z(:,1);

        end
    % ---------------------------------------------------------------------
    case 'cylinder_conductor'
        %-------------------- Constants -----------------------------------
        mu0 = 4*pi*1e-7;
        %------------------------------------------------------------------
        Rho = 1/sigma;
        W   = 2*pi*fr;
        T   = sqrt(-1j*W*mu0*sigma);
        r   = linspace(0,r_conductor,nb_point_r);
        skdepth = sqrt(2/W/sigma/mu0);
        % Rs and q
        Rs  = 1/sigma/skdepth;     % surface resistance
        q   = sqrt(2)*r_conductor./skdepth; % coef
        % Ber, Bei, Ber' et Bei'
        Ber  = real(besselj(0,q.*(1j^(-1/2))));
        Bei  = imag(besselj(0,q.*(1j^(-1/2))));
        dBer = real(1/2 .* 1j^(-1/2).* ...
               (besselj(-1,q.*(1j^(-1/2))) - besselj(1,q.*(1j^(-1/2)))));
        dBei = imag(1/2 .* 1j^(-1/2).* ...
               (besselj(-1,q.*(1j^(-1/2))) - besselj(1,q.*(1j^(-1/2)))));
        %------------------------------------------------------------------
        result.Z = 1j .* Rs/(sqrt(2)*pi*r_conductor) .* ...
                   (Ber  + 1j.*Bei) ./ (dBer + 1j.*dBei);
        %------------------------------------------------------------------
        J0  = besselj(0,T.*r);
        dJ0 = 1/2.*(besselj(-1,T*r_conductor) - besselj(1,T*r_conductor));
        %------------------------------------------------------------------
        result.J = - i_conductor*T/(2*pi*r_conductor) .* J0./dJ0;
        result.r = r;
        %------------------------------------------------------------------
end

% ----------------------------- integrals ---------------------------------

function integ = int_top_plate_eq74(alp,r1,r2,mu,sig_1,sig_2,x,l1,l2,c,z,omega)
    % equation (74), p.2835
    I  = integral(@(t)t.*besselj(1,t),alp*r1,alp*r2); % equation (70), p.2834
    Alpha_1 = sqrt(alp^2 + 1j*omega*mu*sig_1);
    Alpha_2 = sqrt(alp^2 + 1j*omega*mu*sig_2);
    aa = I.*besselj(1,alp.*x).*(exp(-alp*l1)-exp(-alp*l2));
    bb = alp*(Alpha_1 + Alpha_2).*exp(2*Alpha_1*c).*exp(Alpha_1.*z);
    cc = alp*(Alpha_1 - Alpha_2).*exp(-Alpha_1.*z);
    dd = (alp-Alpha_1) * (Alpha_1-Alpha_2) + (alp+Alpha_1) * (Alpha_1+Alpha_2) * exp(2*Alpha_1*c);
    integ = ((1/(alp^3)).*aa).*((bb+cc)/dd);
end

function integ = int_bottom_plate_eq75(alp,r1,r2,mu,sig_1,sig_2,x,l1,l2,c,z,omega)
    % equation (75), p.2835
    I  = integral(@(t)t.*besselj(1,t),alp*r1,alp*r2);
    Alpha_1 = sqrt(alp^2+1j*omega*mu*sig_1);
    Alpha_2 = sqrt(alp^2+1j*omega*mu*sig_2);
    integ = ...
       1/(alp^3)*I*besselj(1,alp*x)*(exp(-alp*l1)-exp(-alp*l2)) .*...
         (2*alp*Alpha_1*exp((Alpha_1+Alpha_2)*c)*exp(Alpha_2*z)) ./ ...
        ((alp-Alpha_1)*(Alpha_1-Alpha_2)+(alp+Alpha_1)*(Alpha_1+Alpha_2)*exp(2*Alpha_1*c));
end

% end all

end






