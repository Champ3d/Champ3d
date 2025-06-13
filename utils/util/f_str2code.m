function code = f_str2code(str,args)
% F_STR2CODE returns the unique code corresponding to the string.
%--------------------------------------------------------------------------
% code = F_STR2CODE(str);
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

arguments
    str
    args.code_type {mustBeMember(args.code_type,{'real','integer'})} = 'real'
end

typestr = class(str);
mnum = 1.141592653589793;

switch typestr
    case 'cell'
        lencell = length(str);
        code = zeros(1,lencell);
        for i = 1:lencell
            mystr = replace(str{i},'...','');
            lenstr = length(mystr);
            for j = 1:lenstr
                code(i) = code(i) + mnum^j * mystr(j);
            end
        end
    case 'char'
        code = 0;
        str = replace(str,'...','');
        lenstr = length(str);
        for i = 1:lenstr
            code = code + mnum^i * str(i);
        end
end
%--------------------------------------------------------------------------
switch args.code_type
    case 'real'
        code = log10(code);
    case 'integer'
        code = round(log10(code) * 1e6); % 1e6 adapted to limit of FEMM gr number
end
%--------------------------------------------------------------------------
end