function f_femm_addcircprop(varargin)

%--------------------------------------------------------------------------
% Call mi_addcircprop
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
arglist = {'id_circuit','i','circuit_type'};

% --- default input value
id_circuit = 'circuit';
i = 0;
circuit_type = 'parallel'; % 'parallel', 'series'


%--------------------------------------------------------------------------
% --- check and update input
for k = 1:(nargin)/2
    if any(strcmpi(arglist,varargin{2*k-1}))
        eval([lower(varargin{2*k-1}) '= varargin{2*k};']);
    else
        error([mfilename ': #' varargin{2*k-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
switch circuit_type
    case {'par', 'parallel'}
        circuit_type = 0;
    case {'ser', 'series'}
        circuit_type = 1;
end

%--------------------------------------------------------------------------
mi_addcircprop(id_circuit,i,circuit_type);
%--------------------------------------------------------------------------


