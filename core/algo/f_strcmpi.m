function cmpresult = f_strcmpi(str1,str2,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


str1 = f_to_scellargin(str1);
str2 = f_to_scellargin(str2);
%--------------------------------------------------------------------------
len = length(str1);
cmpresult = zeros(1,len);
%--------------------------------------------------------------------------
for i = 1:len
    s1 = str1{i};
    if ischar(s1)
        cmpresult(i) = any(strcmpi(s1,str2));
    else
        cmpresult(i) = 0;
    end
end
%--------------------------------------------------------------------------