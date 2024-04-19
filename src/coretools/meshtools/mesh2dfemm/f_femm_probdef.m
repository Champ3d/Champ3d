function f_femm_probdef(varargin)
%--------------------------------------------------------------------------
% Call mi_probdef
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
arglist = {'fr','unit','problem_type','precision','depth','min_angle','acsolver'};

% --- default input value
fr = 0;
unit = 'meters';
problem_type = 'planar'; % 'planar', 'axi
precision = 1E-08;
depth = 0;
min_angle = 10;
acsolver = 'newton'; % 'newton', 'successive_approximation'
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if strcmpi(acsolver,'newton')
    acsolver = 1;
else
    acsolver = 0;
end
%--------------------------------------------------------------------------
mi_probdef(fr, unit, problem_type, precision, depth, min_angle, acsolver);
%--------------------------------------------------------------------------


