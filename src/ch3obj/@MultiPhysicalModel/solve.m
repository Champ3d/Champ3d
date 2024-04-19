%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function solve(obj,args)
arguments
    obj
    args.coupling_scheme {mustBeMember(args.coupling_scheme,{'weak','strong'})} = 'weak';
    args.emcoupling {mustBeMember(args.emcoupling,{'DomainDecomposition'})} = 'DomainDecomposition'
end
% ---
if any(f_strcmpi(args.coupling_scheme,{'weak'}))
    argu = f_to_namedarg(args);
    % ---
    solveweak(obj,argu{:})
elseif any(f_strcmpi(args.coupling_scheme,{'strong'}))
    argu = f_to_namedarg(args);
    % ---
    solvestrong(obj,argu{:})
end



