function dcellargin = f_to_dcellargin(argin,varargin)
%F_TO_DCELLARGIN : returns a double cell argin from single cell or string
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'duplicate'};

% --- default input value
duplicate = 0;

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
tocellargin = {};
if ~iscell(argin)
    tocellargin = {{argin}};
else
    lenargin = length(argin);
    has_cell = 0;
    for i = 1:lenargin
        has_cell = has_cell + iscell(argin{i});
    end
    if ~has_cell
        tocellargin = {argin};
    else
        for i = 1:lenargin
            if iscell(argin{i})
                tocellargin{i} = argin{i};
            else
                tocellargin{i} = {argin{i}};
            end
        end
    end
end

%--------------------------------------------------------------------------
dcellargin = {};
if duplicate > 1
    for i = 1:duplicate
        lencell = length(tocellargin);
        for j = 1:lencell
            dcellargin{(i-1) * lencell + j} = tocellargin{j};
        end
    end
else
    dcellargin = tocellargin;
end



