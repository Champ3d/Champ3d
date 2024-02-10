function named_arguments = f_struct2namedarg(str)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

named_arguments = {};
arg_name = fieldnames(str);
nb_arg = length(arg_name);
for i = 1:nb_arg
    named_arguments{2*(i-1)+1} = arg_name{i};
    named_arguments{2*i}       = str.(arg_name{i});
end