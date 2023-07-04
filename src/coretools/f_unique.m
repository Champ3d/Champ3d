function [mat,imat,ibygroupe] = f_unique(mat,varargin)
% F_UNIQUE returns the unique row (or column) of an 2D array.
%--------------------------------------------------------------------------
% [mat,imat] = f_unique(mat,'urow');
% [mat,imat] = f_unique(mat,'ucol');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'position','by','get'};

% --- default input value
position = 1; % index of the dimension
get = []; % 'group' = 'groupsort' = 'gr'
by  = []; % 'strict' = 'strict_value' = 'strictvalue'
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
mnum = 1.141592653589793;
%--------------------------------------------------------------------------
switch position
    case {1,'urow','row','r'}
        % ---
        position  = 1;
        if any(strcmpi(by,{'strict', 'strict_value', 'strictvalue'}))
            tmat = mat;
        else
            tmat = sort(mat, position);
        end
        smat = size(tmat);
        % ---
        dimm = smat(1);
        mvec = ones(dimm, 1);
        for i = 2:dimm
            mvec(i) = mnum^(i-1);
        end
        magicsum = sum(tmat .* mvec);
        [~,imat] = unique(magicsum);
        mat = mat(:,imat);
    case {2,'ucol','col','c'}
        % ---
        position  = 2;
        if any(strcmpi(by,{'strict', 'strict_value', 'strictvalue'}))
            tmat = mat;
        else
            tmat = sort(mat, position);
        end
        smat = size(tmat);
        % ---
        dimm = smat(2);
        mvec = ones(1, dimm);
        for i = 2:dimm
            mvec(i) = mnum^(i-1);
        end
        magicsum = sum(tmat .* mvec, 2);
        [~,imat] = unique(magicsum);
        mat = mat(imat,:);
end
%--------------------------------------------------------------------------
if any(strcmpi(get,{'group','groupe','gr','groupsort','group_sort'}))
    [~,ibygroupe] = f_groupsort(magicsum);
end
%--------------------------------------------------------------------------
end