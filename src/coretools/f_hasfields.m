function has_fields = f_hasfields(struct_in,fieldnames2test,varargin)
% F_INTKIT3D gives the integral kit.
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh3d : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% mesh3d : mesh data structure with kit added
%--------------------------------------------------------------------------
% EXAMPLE
% mesh3d = F_INTKIT3D(mesh3d);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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









