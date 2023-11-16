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
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
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




