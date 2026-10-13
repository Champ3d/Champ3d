function f_femm_addboundprop(varargin)

%--------------------------------------------------------------------------
% Call mi_addboundprop
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
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

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_bc','a0','a1','a2','phi','mu','sig','c0','c1','bc_type','ia','oa'};

% --- default input value
id_bc = 'bc';
a0  = 0;
a1  = 0;
a2  = 0;
phi = 0;
mu  = 0;
sig = 0;
c0  = 0;
c1  = 0;
ia  = 0;
oa  = 0;
bc_type = 'a=0'; % 'a=0', 'sibc', 'mixed', 
                 % 'dual_image', 'periodic', 'anti-periodic',
                 % 'periodic-airgap', 'anti-periodic-airgap'


%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
switch bc_type
    case 'a=0'
        bc_type = 0;
    case 'sibc'
        bc_type = 1;
    case 'mixed'
        bc_type = 2;
    case 'periodic'
        bc_type = 4;
    case 'anti-periodic'
        bc_type = 5;
end

%--------------------------------------------------------------------------
mi_addboundprop(id_bc, a0, a1, a2, phi, mu, sig, c0, c1, bc_type, ia, oa);
%--------------------------------------------------------------------------


