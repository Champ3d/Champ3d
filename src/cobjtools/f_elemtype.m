function elem_type = f_elemtype(meshorelem,varargin)
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
arglist = {'defined_on'};

% --- default input value
defined_on = 'elem';
elem_type  = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isstruct(meshorelem)
    nbnoinel = size(meshorelem.elem, 1);
    dim = 3;
    if isfield(meshorelem,'node')
        if ~isempty(meshorelem.node)
            dim = size(meshorelem.node,1);
        end
    end
else
    nbnoinel = size(meshorelem, 1);
    dim = 3;
end
%--------------------------------------------------------------------------
if any(f_strcmpi(defined_on,{'elem'}))
    if dim == 3
        switch nbnoinel
            case 4
                elem_type = 'tet';
            case 6
                elem_type = 'prism';
            case 8
                elem_type = 'hex';
        end
    elseif dim == 2
        switch nbnoinel
            case 3
                elem_type = 'tri';
            case 4
                elem_type = 'quad';
        end
    end
elseif any(f_strcmpi(defined_on,{'face'}))
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

