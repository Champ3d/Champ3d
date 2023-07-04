function [vecout,ivec] = f_groupsort(vecin,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
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


