function CoefWn = f_cwn(mesh,varargin)
% F_CWN computes the mass matrix int_v(coef x Wn x dv)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
% 'coef' : coefficient (scalar, tensor or matrix)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWnWn : nb_nodes_in_volume x nb_nodes_in_volume
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWnWn = F_CWN(mesh,'coef',3,'id_elem',[1 2 3]);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'mesh','coef','dim','id_elem'};

% --- default input value
coef = 1;
id_elem = [];
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
con = f_connexion(mesh.elem_type);
nbNo_inEl = con.nbNo_inEl;
nbElem    = mesh.nbElem;
nbNode    = mesh.nbNode;

if isempty(id_elem)
    id_elem = 1:nbElem;
end
%--------------------------------------------------------------------------

matCoef = f_cmatrix(coef,'id_elem',id_elem,'nb_elem',nbElem);

%--------------------------------------------------------------------------
SWnWn = zeros(nbNo_inEl,nbElem);
for iG = 1:con.nbG
    for i = 1:nbNo_inEl
        SWnWn(i,id_elem) = SWnWn(i,id_elem) + ...
            f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.Wn{iG}(i,id_elem));
    end
end
%--------------------------------------------------------------------------
CoefWn = sparse(nbNode,1);

for i = 1:nbNo_inEl
    CoefWn = CoefWn + ...
        sparse(mesh.elem(i,:),1,...
               SWnWn(i,:),nbNode,1);
end

end