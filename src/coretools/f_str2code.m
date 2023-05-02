function code = f_str2code(str)
% F_STR2CODE returns the unique code corresponding to the string.
%--------------------------------------------------------------------------
% code = F_STR2CODE(str);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% length of str should not too high (how many char ?)

typestr = class(str);

switch typestr
    case 'cell'
        lencell = length(str);
        code = zeros(1,lencell);
        for i = 1:lencell
            mystr = replace(str{i},'...','');
            lenstr = length(mystr);
            for j = 1:lenstr
                code(i) = code(i) + pi^j * mystr(j);
            end
        end
    case 'char'
        code = 0;
        str = replace(str,'...','');
        lenstr = length(str);
        for i = 1:lenstr
            code = code + pi^i * str(i);
        end
end
%--------------------------------------------------------------------------
code = log10(code);
%--------------------------------------------------------------------------
end