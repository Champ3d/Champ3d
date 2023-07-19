function cmpresult = f_strcmpi(str1,str2,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


str1 = f_to_scellargin(str1);
str2 = f_to_scellargin(str2);
%--------------------------------------------------------------------------
len = length(str1);
cmpresult = zeros(1,len);
%--------------------------------------------------------------------------
for i = 1:len
    cmpresult(i) = any(strcmpi(str1{i},str2));
end
%--------------------------------------------------------------------------