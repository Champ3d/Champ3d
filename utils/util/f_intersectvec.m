function [vout, ivout] = f_intersectvec(vin1,vin2,varargin)
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
size1 = size(vin1);
dim1  = size1(position);
size2 = size(vin2);
dim2  = size2(position);
%--------------------------------------------------------------------------
if dim1 ~= dim2
    error([mfilename ': #vin1 and #vin2 do not have the same dimension !']);
end
%--------------------------------------------------------------------------
if position > 2 || position < 1
    error([mfilename ': #vin1 and #vin2 must have dimension-2 !']);
end
%--------------------------------------------------------------------------
svin1 = f_magicsum(vin1,'position',position);
svin2 = f_magicsum(vin2,'position',position);
%--------------------------------------------------------------------------
[~,ivout] = intersect(svin1,svin2);
%--------------------------------------------------------------------------
vout = vin1(:,ivout);
%--------------------------------------------------------------------------

end