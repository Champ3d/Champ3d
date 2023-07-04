function elem_type = f_elemtype(elem,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'defined_on'};

% --- default input value
elem_type  = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
nbnoinel = size(elem, 1);
if any(strcmpi(defined_on,{'elem'}))
    switch nbnoinel
        case 4
            elem_type = 'tet';
        case 6
            elem_type = 'prism';
        case 8
            elem_type = 'hex';
    end
elseif any(strcmpi(defined_on,{'face'}))
    switch nbnoinel
        case 3
            elem_type = 'tri';
        case 4
            elem_type = 'quad';
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ': cannot define #elem_type!']);
end

