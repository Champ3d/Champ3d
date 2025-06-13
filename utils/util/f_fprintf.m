function f_fprintf(varargin)
% F_FPRINTF
% (format1,'str1',...)
% format :
% + 0 : black
% + 1 : red
% + 2 : orange/yellow
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

len = length(varargin);
if mod(len,2) ~= 0
    error([mfilename ': give arguments in pairs (format1,string1,...). \n']);
end

%--------------------------------------------------------------------------
form = {};
str  = {};
for i = 1:len/2
    %----------------------------------------------------------------------
    f = varargin{2*i - 1};
    if isnumeric(f)
        if numel(f) == 1
            if any(f == [0 1 2])
                form{i} = f;
            end
        end
    else
        form{i} = 0;
    end
    %----------------------------------------------------------------------
    s = varargin{2*i};
    if isnumeric(s)
        if numel(s) == 1
            str{i} = num2str(s);
        else
            str{i} = [num2str(s(1)) ',' num2str(s(2)) '...'];
        end
    elseif ischar(s)
        str{i} = s;
    else
        str{i} = '___';
    end
end
%--------------------------------------------------------------------------
for i = 1:len/2
    f = form{i};
    s = str{i};
    switch f
        case 0
            if isempty(strfind(s,'\n'))
                fprintf([' ' s ' ']);
            else
                fprintf([' ' s]);
            end
        case 1
            fprintf(2,[' ' s ' ']);
        case 2
            fprintf(['[\b ' s ' ]\b']);
        otherwise
            fprintf([' ' s ' ']);
    end
end












