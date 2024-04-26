function boolargout = f_istrue(boolargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

if isempty(boolargin)
    boolargout = 0;
elseif isnumeric(boolargin)
    if boolargin > 0
        boolargout = 1;
    else
        boolargout = 0;
    end
elseif ischar(boolargin)
    if any(strcmpi(boolargin,{'no','off'}))
        boolargout = 0;
    elseif any(strcmpi(boolargin,{'yes','on'}))
        boolargout = 1;
    else
        boolargout = 0;
    end
end