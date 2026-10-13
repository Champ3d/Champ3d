function [elem,flag] = f_sortori(elem)
% F_SORTORI returns face-type elements with correctly sorted orientation.
%--------------------------------------------------------------------------
% elem = F_SORTORI(elem);
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
flag = ones(1,size(elem,2));
if size(elem,1) < 2
    return
elseif size(elem,1) == 2
    flag = sign(diff(elem));
    elem = sort(elem); % for 2d
else
    elem(elem == 0) = [];
    dim = size(elem,1); len = size(elem,2);
    [~,imin] = sort(elem); ormin = mod(imin(1,:),dim); ormin(ormin==0) = dim;
    ornex = mod(ormin + 1, dim); ornex(ornex==0) = dim;
    orpre = mod(ormin - 1, dim); orpre(orpre==0) = dim;
    ornex = sub2ind(size(elem),ornex,1:len);
    orpre = sub2ind(size(elem),orpre,1:len);
    ori = elem(orpre) - elem(ornex);
    ie2sort = find(ori < 0);
    elem(:,ie2sort) = elem(end:-1:1,ie2sort);
    flag(ie2sort) = -1;
end














