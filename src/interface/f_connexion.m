function con = f_connexion(elem_type,varargin)
% F_CONNEXION returns the connexion definitions which correspond to a given
% elem_type.
%--------------------------------------------------------------------------
% con = F_CONNEXION('tri');   --> for triangle
% con = F_CONNEXION('prism'); --> for prism
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

switch elem_type
    case {33,'tri'}
        con = f_contri;
    case {44,'quad'}
        con = f_conquad;
    case {46,'tet'}
        con = f_contetra;
    case {69,'prism'}
        con = f_conprism;
    case {812,'hex'}
        con = f_conhexa;
    case 'xxx'
        % con = f_xxx;
end








