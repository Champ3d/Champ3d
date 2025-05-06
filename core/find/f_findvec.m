function ivec = f_findvec(vin,vref,varargin)
% F_FINDVEC returns the idx of vectors in a array of reference vectors
%--------------------------------------------------------------------------
% FIXED INPUT
% vin : nD x nb_vectors
% vref : nD x nb_vectors
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'urow','row','r','ucol','col','c'
%--------------------------------------------------------------------------
% OUTPUT
% ivec : indices of found vectors.
%--------------------------------------------------------------------------
% EXAMPLE
% ivec = F_FINDVEC(vin,vref);
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
arglist = {'position'};

% --- default input value
position = 1; % index of the dimension

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
switch position
    case {1,'urow','row','r'}
        position   = 1;
        [dimref,lenref] = size(vref);
        [dimin ,lenin]  = size(vin);
    case {2,'ucol','col','c'}
        position  = 2;
        [lenref,dimref] = size(vref);
        [lenin ,dimin]  = size(vin);
end
%--------------------------------------------------------------------------
if dimref ~= dimin
    error([mfilename ': #vref and #vin do not have the same dimension !']);
end
%--------------------------------------------------------------------------
svin  = f_magicsum(vin,'position',position);
svref = f_magicsum(vref,'position',position);
%--------------------------------------------------------------------------
iref = 1:lenref;
%-----
ivec = interp1(svref,iref,svin,'nearest');
%--------------------------------------------------------------------------
end