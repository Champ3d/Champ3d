function CoefWeWf = f_cwewf(mesh,varargin)
% F_CWEWF computes the mass matrix int_v(coef x We x Wf x dv)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
%     o default_value = 1:nbElem
% 'coef' : coefficient (scalar, tensor or matrix)
%     o default_value = 1
% 'dim' : dimension
%     o default_value = 3
%--------------------------------------------------------------------------
% OUTPUT
% CoefWeWf : nb_edges_in_volume x nb_faces_in_volume
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWeWf = F_CWEWF(mesh,'coef',3,'id_elem',[1 2 3],'dim',3);
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
nbFa_inEl = con.nbFa_inEl;
nbElem    = mesh.nbElem;
nbEdge    = mesh.nbEdge;
nbFace    = mesh.nbFace;

if isempty(id_elem)
    id_elem = 1:nbElem;
end
%--------------------------------------------------------------------------

matCoef = f_cmatrix(coef,'dim',dim,'id_elem',id_elem,'nb_elem',nbElem);

%--------------------------------------------------------------------------
SWeWf = zeros(nbEd_inEl,nbElem,nbFa_inEl);
for iG = 1:con.nbG
    for i = 1:nbEd_inEl
        for j = 1:nbFa_inEl
            switch dim
                case 3
                    SWeWf(i,id_elem,j) = SWeWf(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(3,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.Wf{iG}(3,j,id_elem)+...
                        matCoef(3,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.Wf{iG}(3,j,id_elem)+...
                        matCoef(3,3,id_elem).*mesh.We{iG}(3,i,id_elem).*mesh.Wf{iG}(3,j,id_elem));
                case 2
                    SWeWf(i,id_elem,j) = SWeWf(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.We{iG}(1,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.We{iG}(2,i,id_elem).*mesh.Wf{iG}(2,j,id_elem));
            end
        end
    end
end
%--------------------------------------------------------------------------
CoefWeWf = sparse(nbEdge,nbFace);

for i = 1:nbEd_inEl
    for j = 1:nbFa_inEl
        CoefWeWf = CoefWeWf + ...
            sparse(mesh.edge_in_elem(i,:),mesh.face_in_elem(j,:),...
                   SWeWf(i,:,j),nbEdge,nbFace);
    end
end


end