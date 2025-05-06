function M1dotM2 = f_dot(M1,M2,varargin)
% F_DOT computes the dot product array of two arrays of vectors
%--------------------------------------------------------------------------
% FIXED INPUT
% M1 : nD x nb_vectors
% M2 : nD x nb_vectors
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% M1dotM2 : 1 x nb_vectors
%--------------------------------------------------------------------------
% EXAMPLE
% M1dotM2 = F_DOT(M1,M2);
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
arglist = {'idim'};

% --- default input value
idim = 1; % index of the dimension

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
M1 = squeeze(M1);
M2 = squeeze(M2);
M1dotM2 = dot(M1,M2,idim);



end