function CoefWfWf = f_cwfwf(mesh,varargin)
% F_CWFWF computes the mass matrix int_v(coef x Wf x Wf x dv)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
% 'coef' : coefficient (scalar, tensor or matrix)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWfWf : nb_faces_in_volume x nb_faces_in_volume
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWfWf = F_CWFWF(mesh,'coef',3,'id_elem',[1 2 3]);
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
nbFa_inEl = con.nbFa_inEl;
nbElem    = mesh.nbElem;
nbFace    = mesh.nbFace;

if isempty(id_elem)
    id_elem = 1:nbElem;
end
%--------------------------------------------------------------------------

matCoef = f_cmatrix(coef,'dim',dim,'id_elem',id_elem,'nb_elem',nbElem);

%--------------------------------------------------------------------------

SWfWf = zeros(nbFa_inEl,nbElem,nbFa_inEl);
for iG = 1:con.nbG
    for i = 1:nbFa_inEl
        for j = i:nbFa_inEl % !!! i
            switch dim
                case 3
                    SWfWf(i,id_elem,j) = SWfWf(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.Wf{iG}(1,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.Wf{iG}(2,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,3,id_elem).*mesh.Wf{iG}(3,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.Wf{iG}(1,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.Wf{iG}(2,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,3,id_elem).*mesh.Wf{iG}(3,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(3,1,id_elem).*mesh.Wf{iG}(1,i,id_elem).*mesh.Wf{iG}(3,j,id_elem)+...
                        matCoef(3,2,id_elem).*mesh.Wf{iG}(2,i,id_elem).*mesh.Wf{iG}(3,j,id_elem)+...
                        matCoef(3,3,id_elem).*mesh.Wf{iG}(3,i,id_elem).*mesh.Wf{iG}(3,j,id_elem));
                case 2
                    SWfWf(i,id_elem,j) = SWfWf(i,id_elem,j) + ...
                        f_multrowv(con.Weigh(iG).*mesh.detJ{iG}(id_elem),...
                        matCoef(1,1,id_elem).*mesh.Wf{iG}(1,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(1,2,id_elem).*mesh.Wf{iG}(2,i,id_elem).*mesh.Wf{iG}(1,j,id_elem)+...
                        matCoef(2,1,id_elem).*mesh.Wf{iG}(1,i,id_elem).*mesh.Wf{iG}(2,j,id_elem)+...
                        matCoef(2,2,id_elem).*mesh.Wf{iG}(2,i,id_elem).*mesh.Wf{iG}(2,j,id_elem));
            end
        end
    end
end
%--------------------------------------------------------------------------

CoefWfWf = sparse(nbFace,nbFace);

for i = 1:nbFa_inEl
    for j = i+1 : nbFa_inEl
        CoefWfWf = CoefWfWf + ...
            sparse(mesh.face_in_elem(i,:),mesh.face_in_elem(j,:),...
                   SWfWf(i,:,j),nbFace,nbFace);
    end
end

CoefWfWf = CoefWfWf + CoefWfWf.';

for i = 1:nbFa_inEl
    CoefWfWf = CoefWfWf + ...
        sparse(mesh.face_in_elem(i,:),mesh.face_in_elem(i,:),...
               SWfWf(i,:,i),nbFace,nbFace);
end


end