%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function colarray = f_column_array(coef,args)
arguments
    coef
    args.nb_elem = 1
end
% ---
nb_elem = args.nb_elem;
% ---
colx = f_column_format(coef);
if numel(colx) == 1
    colarray = repmat(colx,nb_elem,1);
else
    colarray = colx;
end
