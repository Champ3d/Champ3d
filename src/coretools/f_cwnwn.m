function CoefWnWn = f_cwnwn(mesh,varargin)
% F_COEFWNWN computes the mass matrix int_v(coef x Wn x Wn x dv)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
% 'coef' : coefficient (scalar, tensor or matrix)
% 'elem_type' : element type ('prism','hex','tet', ...)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWnWn : nb_nodes_in_volume x nb_nodes_in_volume
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWnWn = F_COEFWNWN(mesh,'coef',3,'id_elem',[1 2 3],'elem_type','prism');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'mesh','coef','id_elem'};

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

SWnWn = zeros(nbNo_inEl,nbElem,nbNo_inEl);
for iG = 1:con.nbG
    for i = 1:nbNo_inEl
        for j = i:nbNo_inEl % !!! i
            SWnWn(i,id_elem,j) = SWnWn(i,id_elem,j) + ...
                f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                squeeze(matCoef(1,1,id_elem)).'.*mesh.Wn{iG}(i,id_elem).*mesh.Wn{iG}(j,id_elem));
        end
    end
end
%--------------------------------------------------------------------------

CoefWnWn = sparse(nbNode,nbNode);

for i = 1:nbNo_inEl
    for j = i+1 : nbNo_inEl
        CoefWnWn = CoefWnWn + ...
            sparse(mesh.elem(i,:),mesh.elem(j,:),...
                   SWnWn(i,:,j),nbNode,nbNode);
    end
end

CoefWnWn = CoefWnWn + CoefWnWn.';

for i = 1:nbNo_inEl
    CoefWnWn = CoefWnWn + ...
        sparse(mesh.elem(i,:),mesh.elem(i,:),...
               SWnWn(i,:,i),nbNode,nbNode);
end

end