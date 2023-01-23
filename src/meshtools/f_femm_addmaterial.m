function f_femm_addmaterial(varargin)

% - material_name Material name
% - mu x Relative permeability in the x- or r-direction.
% - mu y Relative permeability in the y- or z-direction.
% - Hc Permanent magnet coercivity in Amps/Meter.
% - J Applied source current density in Amps/mm2.
% - sigma Electrical conductivity of the material in MS/m.
% - Lam_d Lamination thickness in millimeters.
% - Phi_hmax Hysteresis lag angle in degrees, used for nonlinear BH curves.
% - Lam_fill Fraction of the volume occupied per lamination that is actually
%       filled with iron (Note that this parameter defaults to 1 in the 
%       femm preprocessor dialog box because, by default, iron completely 
%       fills the volume)
% - Lamtype Set to
%   + 0 ? Not laminated or laminated in plane
%   + 1 ? laminated x or r
%   + 2 ? laminated y or z
%   + 3 ? magnet wire
%   + 4 ? plain stranded wire
%   + 5 ? Litz wire
%   + 6 ? square wire
% - Phi_hx Hysteresis lag in degrees in the x-direction for linear problems.
% - Phi_hy Hysteresis lag in degrees in the y-direction for linear problems.
% - nstr Number of strands in the wire build. Should be 1 for Magnet or Square wire.
% - dwire Diameter of each of the wire?s constituent strand in millimeters.
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


% --- valid argument list (to be updated each time modifying function)
arglist = {'material_name','mur','mur_x','mur_y','Br',...
           'Hc','J','sigma','Lam_d','Phi_hmax','lam_fill','LamType',...
           'Phi_hx','Phi_hy','nstr','dwire'};

% --- default input value
material_name = [];
mur      = 1;
mur_x    = [];
mur_y    = [];
br       = 0;
hc       = [];
j        = 0;
sigma    = 0;
lam_d    = 0;
phi_hmax = 0;
lam_fill = 0;
lamtype  = 0;
phi_hx   = 0;
phi_hy   = 0;
nstr     = 0;
dwire    = 0;

% --- check and update input
for i = 1:nargin/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
if isempty(mur_x)
    mur_x = mur;
end
if isempty(mur_y)
    mur_y = mur;
end
if isempty(hc)
    hc = br/(4*pi*1e-7 * mur);
end
% -------------------------------------------------------------------------
mi_addmaterial(material_name,mur_x,mur_y,hc,j/1e6,sigma/1e6,lam_d,phi_hmax,...
               lam_fill,lamtype,phi_hx,phi_hy,nstr,dwire);
% -------------------------------------------------------------------------
