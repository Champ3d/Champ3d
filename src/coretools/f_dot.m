function M1dotM2 = f_dot(M1,M2,varargin)
% F_DOT computes the dot product array of two arrays of vectors
%--------------------------------------------------------------------------
% FIXED INPUT
% M1 : nD x nb_vectors
% M2 : nD x nb_vectors
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% M1dotM2 : 1 x nb_vectors
%--------------------------------------------------------------------------
% EXAMPLE
% M1dotM2 = F_DOT(M1,M2);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

M1 = squeeze(M1);
M2 = squeeze(M2);
M1dotM2 = sum(M1.*M2);

end