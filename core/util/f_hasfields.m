function has_fields = f_hasfields(struct_in,fieldnames2test,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'options'};

% --- default input value
options = '_all'; % 'at_least_one'

% --- default output value


% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
options = f_to_scellargin(options);
%--------------------------------------------------------------------------
fieldnames2test = f_to_scellargin(fieldnames2test);
%--------------------------------------------------------------------------
allfields = fieldnames(struct_in);
%--------------------------------------------------------------------------
if any(f_strcmpi(options,'at_least_one'))
    % ---
    has_fields = 0;
    % ---
    for i = 1:length(fieldnames2test)
        fn = fieldnames2test{i};
        if any(strcmpi(fn,allfields))
            has_fields = 1;
            break;
        end
    end
else
    % ---
    has_fields = 1;
    % ---
    for i = 1:length(fieldnames2test)
        fn = fieldnames2test{i};
        if ~any(strcmpi(fn,allfields))
            has_fields = 0;
            break;
        end
    end
end









