function mesh = f_make_mds(node,elem,elem_type,varargin)
% F_MAKE_MDS returns the dot product array of two arrays of vectors (matrix = dim x nbVectors)
%--------------------------------------------------------------------------
% mesh = F_MAKE_MDS(node,elem,'prism','full');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if nargin <= 3
    option = 'full';
else
    option = varargin{1};
end

switch elem_type
    case {33,'tri'}
        mesh = f_mdstri(node,elem,option);
    case {44,'quad'}
        mesh = f_mdsquad(node,elem,option);
    case {46,'tet'}
        mesh = f_mdstetra(node,elem,option);
    case {69,'prism'}
        mesh = f_mdsprism(node,elem,option);
    case {690,'prismx'}
        
    case {812,'hex'}
        mesh = f_mdshexa(node,elem,option);
end

end