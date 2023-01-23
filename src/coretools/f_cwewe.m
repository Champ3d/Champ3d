function CoefWeWe = f_cwewe(mesh,varargin)
% F_CWEWE computes the mass matrix int_v(coef x We x We x dv)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
% 'coef' : coefficient (scalar, tensor or matrix)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWeWe : nb_edges_in_volume x nb_edges_in_volume
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWeWe = F_CWEWE(mesh,'coef',1,'id_elem',[1 2 3],'dim',3);
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
dim  = 3;
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
nbEd_inEl = con.nbEd_inEl;
nbElem    = mesh.nbElem;
nbEdge    = mesh.nbEdge;

if isempty(id_elem)
    id_elem = 1:nbElem;
end
%--------------------------------------------------------------------------

matCoef = f_cmatrix(coef,'dim',dim,'id_elem',id_elem,'nb_elem',nbElem);

%--------------------------------------------------------------------------

SWeWe = zeros(nbEd_inEl,nbElem,nbEd_inEl);
for iG = 1:con.nbG
    for i = 1:nbEd_inEl
        for j = i:nbEd_inEl % !!! i
            switch dim
                case 3
                    SWeWe(i,id_elem,j) = SWeWe(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.We{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.We{iG}(1,j,id_elem)+...
                        matCoef(1,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.We{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.We{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.We{iG}(2,j,id_elem)+...
                        matCoef(2,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.We{iG}(2,j,id_elem)+...
                        matCoef(3,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.We{iG}(3,j,id_elem)+...
                        matCoef(3,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.We{iG}(3,j,id_elem)+...
                        matCoef(3,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.We{iG}(3,j,id_elem));
                case 2
                    SWeWe(i,id_elem,j) = SWeWe(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.We{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.We{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.We{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.We{iG}(2,j,id_elem));
            end
        end
    end
end
%--------------------------------------------------------------------------
CoefWeWe = sparse(nbEdge,nbEdge);

for i = 1:nbEd_inEl
    for j = i+1 : nbEd_inEl
        CoefWeWe = CoefWeWe + ...
            sparse(mesh.edge_in_elem(i,:),mesh.edge_in_elem(j,:),...
                   SWeWe(i,:,j),nbEdge,nbEdge);
    end
end

CoefWeWe = CoefWeWe + CoefWeWe.';

for i = 1:nbEd_inEl
    CoefWeWe = CoefWeWe + ...
        sparse(mesh.edge_in_elem(i,:),mesh.edge_in_elem(i,:),...
               SWeWe(i,:,i),nbEdge,nbEdge);
end





