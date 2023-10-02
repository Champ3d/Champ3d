function nb_argin = f_nargin(f2check)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


nb_argin = nargin(f2check);

if nb_argin < 0
    nb_argin = abs(nb_argin) - 1;
end


