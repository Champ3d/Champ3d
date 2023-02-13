function bound = f_boface(node,elem,elem_type)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

bcmesh = f_make_mds(node,elem,elem_type);
bound  = bcmesh.bound;





