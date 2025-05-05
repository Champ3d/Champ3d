function [mat,imat,ibygroupe] = f_unique(mat,varargin)
% F_UNIQUE returns the unique row (or column) of an 2D array.
%--------------------------------------------------------------------------
% [mat,imat] = f_unique(mat,'urow');
% [mat,imat] = f_unique(mat,'ucol');
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'position','by','get'};

% --- default input value
position = 1; % index of the dimension
get = []; % 'group' = 'groupsort' = 'gr'
by  = []; % 'strict' = 'strict_value' = 'strictvalue'
% --- default output value
imat = [];
ibygroupe = [];
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
if isempty(mat)
    return
elseif isobject(mat)
    return
elseif iscell(mat)
    % --- work with obj references
    if length(mat) == 1
        return
    else
        i = 1;
        while i <= length(mat)
            j = i+1;
            while j <= length(mat)
                if mat{j} == mat{i}
                    mat(j) = [];
                end
                j = j+1;
            end
            % ---
            i = i+1;
        end
    end
    return
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