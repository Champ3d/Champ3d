function parameter = f_calbhdata(parameter,varargin)
% F_CALBHDATA processes bh data
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

bdata = parameter.b;
hdata = parameter.h;

%--------------------------------------------------------------------------
% --- filtering

%--------------------------------------------------------------------------
% --- cubic spline interpolation
b = linspace(min(bdata),max(bdata),1000);
h = spline(bdata,hdata,b);
%--------------------------------------------------------------------------
% --- cleaning
if b(1) == 0 || h(1) == 0
    b(1) = [];
    h(1) = [];
end
%--------------------------------------------------------------------------
% --- compute mu et nu
mu0 = 4*pi*1e-7;
mur = b./h./mu0;   % relative permeability
nur = 1./mur;      % relative reluctivity
%--------------------------------------------------------------------------
murjw = b./h./mu0;   % relative permeability
nurjw = 1./murjw;      % relative reluctivity
%--------------------------------------------------------------------------
% --- compute differentials
dnur = diff(nur);
dmur = diff(mur);
dB  = diff(b);
dH  = diff(h);
%--------------------------------------------------------------------------
% --- cleaning
b(end) = [];
h(end) = [];
mur(end) = [];
nur(end) = [];
murjw(end) = [];
nurjw(end) = [];
%--------------------------------------------------------------------------
% --- compute H2xdmu/dH2, B2xdnu/dB2, Bxdnu/dB
dnurdb = dnur./dB;
dmurdh = dmur./dH;
% dnudb2 = dnu./dB2;
% dmudh2 = dmu./dH2;

%--------------------------------------------------------------------------
% --- compute H2xdmu/dH2, B2xdnu/dB2, Bxdnu/dB
dnurdbjw = dnur./dB;
dmurdhjw = dmur./dH;

%--------------------------------------------------------------------------
% --- output
parameter.b = b;
parameter.h = h;
parameter.mur = mur;
parameter.nur = nur;
parameter.dnurdb = dnurdb;
parameter.dmurdh = dmurdh;
% ---
parameter.murjw = murjw;
parameter.nurjw = nurjw;
parameter.dnurdbjw = dnurdbjw;
parameter.dmurdhjw = dmurdhjw;






