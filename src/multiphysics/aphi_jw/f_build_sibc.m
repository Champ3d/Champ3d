function SYsibcWeWe = f_build_sibc(mesh,varargin)
% F_MAKESIBC ...
%--------------------------------------------------------------------------
% SWeWeS = F_MAKESIBC(mesh,'id_face',id_face,'fr',fr,'gtsigma',gtsigma,'gtsigma',gtmur)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of St-Nazaire, University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

for i = 1:(nargin-1)/2
    eval([lower(varargin{2*i-1}) ' = varargin{2*i};']);
end

%--------------------------------------------------------------------------

mu0 = 4*pi*1e-7;
sig = det(gtsigma)^(1/3);
mu  = mu0 *  det(gtmur)^(1/3);

skindepth = sqrt(2/(2*pi*fr*mu*sig));

if ~exist('cparam','var')
    Zsibc = (1+1j)/(skindepth*sig);
else
    Zsibc = (1+1j)/(skindepth*sig) * (1 + (1-1j)/4 * skindepth * 1/cparam);
end

[face,id_face_sibc] = f_filterface(mesh.face(:,id_face));
for i = 1:length(face)
    id_face_sibc{i} = id_face(id_face_sibc{i});
end


%--------------------------------------------------------------------------

nbElem = mesh.nbElem;
nbEdge = mesh.nbEdge;
nbFace = mesh.nbFace;
con = f_connexion(mesh.elem_type);

%--------------------------------------------------------------------------
SYsibcWeWe = sparse(nbEdge,nbEdge);
% SnuWfWfS   = sparse(nbFace,nbFace);
% nuWfWfS    = zeros(1,nbFace);
for i = 1:length(face)
    idgFace = id_face_sibc{i};
    [flatnode,flatface] = f_flatface(mesh.node,...
                                     mesh.face(:,idgFace));
    if size(flatface,1) == 3
        mesh_sibc = f_mdstri(mesh.node,flatface);
        id_ledge = [];
        id_gedge = [];
        for j = 1:3
            id_ledge = [id_ledge mesh_sibc.edge_in_elem(j,:)];
            id_gedge = [id_gedge mesh.edge_in_face(j,idgFace)];
        end
        idgEdge = zeros(1,mesh_sibc.nbEdge);
        idgEdge(id_ledge) = id_gedge;
    elseif size(flatface,1) == 4
        mesh_sibc = f_mdsquad(mesh.node,flatface);
        id_ledge = [];
        id_gedge = [];
        for j = 1:4
            id_ledge = [id_ledge mesh_sibc.edge_in_elem(j,:)];
            id_gedge = [id_gedge mesh.edge_in_face(j,idgFace)];
        end
        idgEdge = zeros(1,mesh_sibc.nbEdge);
        idgEdge(id_ledge) = id_gedge;
    end
    mesh_sibc = f_intkit2d(mesh_sibc,'flatnode',flatnode);
    SYsibcWeWe(idgEdge,idgEdge) = SYsibcWeWe(idgEdge,idgEdge) + f_coefWeWe(mesh_sibc,'coef',1/Zsibc,'dim',2);
    % nuWfWfS(idgFace) = 1/mu .* mesh_sibc.elem_size .* skindepth;
    % SnuWfWfS(1:nbFace+1:end) = SnuWfWfS(1:nbFace+1:end) + nuWfWfS;
end

