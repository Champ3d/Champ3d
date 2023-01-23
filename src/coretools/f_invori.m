function element = f_invori(element)
% F_INVORI inverses the orientation of all face-type elements.
%--------------------------------------------------------------------------
% FIXED INPUT
% element : nb_nodes_per_elem x nb_elem
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% element : nb_nodes_per_elem x nb_elem
%--------------------------------------------------------------------------
% EXAMPLE
% element = F_INVORI(element);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

[r,c] = find(element == 0);
ir = unique(r);
gr = {};
for i = 1:length(ir)
    gr{i} = find(r == ir(i));
end
for i = 1:size(gr,2)
    iElem = c(gr{i});
    element(1:ir(i)-1,iElem) = element(ir(i)-1:-1:1,iElem);
end
%-----
n = setdiff(1:size(element,2),c);
element(:,n) = element(end:-1:1,n);




