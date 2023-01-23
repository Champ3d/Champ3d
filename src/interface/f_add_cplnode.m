function cnode = f_add_cplnode(varargin)
% F_ADD_CNODE ...
%--------------------------------------------------------------------------
% couling_node = F_ADD_CNODE();
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
if nargin > 0
    datin = [];
    for i = 1:nargin/2
        datin.(varargin{2*i-1}) = varargin{2*i};
    end
    cnode = coupling_node(datin);
else
    cnode = coupling_node();
end

end









