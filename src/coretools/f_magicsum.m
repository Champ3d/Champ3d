function magicsum = f_magicsum(mat,varargin)
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
        mat  = sort(mat, position);
        smat = size(mat);
        % ---
        dimm = smat(1);
        mvec = ones(dimm, 1);
        for i = 2:dimm
            mvec(i) = mnum^(i-1);
        end
        magicsum = sum(mat .* mvec);
    case {2,'ucol','col','c'}
        % ---
        position  = 2;
        mat  = sort(mat, position);
        smat = size(mat);
        % ---
        dimm = smat(2);
        mvec = ones(1, dimm);
        for i = 2:dimm
            mvec(i) = mnum^(i-1);
        end
        magicsum = sum(mat .* mvec, 2);
end
%--------------------------------------------------------------------------
end