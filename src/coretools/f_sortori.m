function [elem,flag] = f_sortori(elem)
% F_SORTORI returns face-type elements with correctly sorted orientation.
%--------------------------------------------------------------------------
% elem = F_SORTORI(elem);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
flag = ones(1,size(elem,2));
if size(elem,1) < 2
    return
elseif size(elem,1) == 2
    elem = sort(elem);
    flag(:) = 1;
else
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














