function f_comparestruct(str1, str2, varargin)
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
arglist = {'field_name'};

% --- default input value
field_name = 'all';

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if any(strcmpi({'all','all_fields','all_field'},field_name))
    field_name = fieldnames(str1);
end
%--------------------------------------------------------------------------
if ~isempty(field_name)
    lenfn = length(field_name);
    fprintf('Comparison_______________________________________________\n');
    for i = 1:lenfn
        fn = field_name{i};
        if isfield(str1,fn) && isfield(str2,fn)
            if isnumeric(str1.(fn)) && isnumeric(str2.(fn))
                if all(size(str1.(fn)) == size(str2.(fn)))
                    eq = all(find(str1.(fn) - str2.(fn)));
                else
                    eq = 0;
                end
            end
            if ischar(str1.(fn)) && ischar(str2.(fn))
                eq = strcmp(str1.(fn), str2.(fn));
            end
            if eq == 1
                mess = 'equal';
            else
                mess = 'not-equal';
            end
            str_out = ['/' fn '/'];
            f_print({str_out,'is',mess},'pad_len',30);
        end
    end
    fprintf('_________________________________________________________\n');
end
%--------------------------------------------------------------------------
end