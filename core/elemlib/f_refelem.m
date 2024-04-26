%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function refelem = f_refelem(elem_type)
arguments
    elem_type {mustBeMember(elem_type,{'tri','triangle','quad','tet','tetra','prism','hex','hexa'})}
end

switch elem_type
    case {33,'tri','triangle'}
        refelem = TriMesh.reference;
    case {44,'quad'}
        refelem = QuadMesh.reference;
    case {46,'tet','tetra'}
        refelem = TetMesh.reference;
    case {69,'prism'}
        refelem = PrismMesh.reference;
    case {812,'hex','hexa'}
        refelem = HexMesh.reference;
    case 'xxx'
        % ---
end








