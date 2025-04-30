function elem_type = f_elemtype(elem,args)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

arguments
    elem
    args.defined_on {mustBeMember(args.defined_on,{'elem','face'})} = 'elem'
    args.dim = 3
end

% --- default
defined_on = args.defined_on;
elem_type  = [];
%--------------------------------------------------------------------------
nbnoinel = size(elem, 1);
dim = args.dim;
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

