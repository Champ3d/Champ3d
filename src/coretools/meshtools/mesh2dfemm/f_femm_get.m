function fvalue = f_femm_get(x,y,varargin)
%--------------------------------------------------------------------------
% Call mo_getj
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
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
arglist = {'field_name'};

% --- default input value
field_name = '';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

if any(f_strcmpi(field_name,{'j'}))
    fvalue = mo_getj(x,y); % MA/m^2
    fvalue = 1e6 .* fvalue;     %  A/m^2
elseif any(f_strcmpi(field_name,{'b'}))
    fvalue = mo_getb(x,y); % Tesla
end









