function code = f_str2code(str)
% F_STR2CODE returns the unique code corresponding to the string.
%--------------------------------------------------------------------------
% code = F_STR2CODE(str);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

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
code = log10(code);
%--------------------------------------------------------------------------
end