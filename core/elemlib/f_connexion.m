function con = f_connexion(elem_type,varargin)
% F_CONNEXION returns the connexion definitions which correspond to a given
% elem_type.
%--------------------------------------------------------------------------
% con = F_CONNEXION('tri');   --> for triangle
% con = F_CONNEXION('prism'); --> for prism
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

switch elem_type
    case {33,'tri','triangle'}
        con = f_contri;
    case {44,'quad'}
        con = f_conquad;
    case {46,'tet','tetra'}
        con = f_contetra;
    case {69,'prism'}
        con = f_conprism;
    case {812,'hex','hexa'}
        con = f_conhexa;
    case 'xxx'
        % con = f_xxx;
end








