function [mat,imat] = f_unique(mat,varargin)
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
arglist = {'position'};

% --- default input value
position = 1; % index of the dimension

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
switch position
    case {1,'urow','row','r'}
        % ---
        position  = 1;
        tmat = sort(mat, position);
        smat = size(mat);
        mnum = sqrt(2);
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
        tmat = sort(mat, position);
        smat = size(mat);
        mnum = sqrt(2);
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
end