function [vecout,ivec] = f_groupsort(vecin,varargin)
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
arglist = {'group_component'};

% --- default input value
group_component = []; % index of the dimension
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
if isempty(group_component)
    [vsorted,iv] = sort(vecin);
elseif isnumeric(group_component)
    [vsorted,iv] = sort(vecin(group_component,:));
end
%--------------------------------------------------------------------------
dvec  = diff([vsorted(1) vsorted]);
idv   = find(dvec ~= 0);
idv   = [1 idv length(vsorted)+1];
ivec  = {};
vecout = {};
for i = 1 : length(idv)-1
    ivec{i} = iv(idv(i) : idv(i+1)-1);
    if isempty(group_component)
        vecout{i} = vecin(ivec{i});
    elseif isnumeric(group_component)
        vecout{i} = vecin(:,ivec{i});
    end
end


