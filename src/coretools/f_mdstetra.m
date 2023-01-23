function mesh = f_mdstetra(node,elem,varargin)
%--------------------------------------------------------------------------
% mesh = f_MDS46(node,elem)
% mesh = f_MDS46(node,elem,'full')
% mesh = f_MDS46(node,elem,'edge','face','interface','bound','D','R','G')
%--------------------------------------------------------------------------
% F_DOT returns the dot product array of two arrays of vectors (matrix = dim x nbVectors)
%--------------------------------------------------------------------------
% M1dotM2 = F_DOT(M1,M2);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
for i = 1:nargin-2
        eval(['datin.' varargin{i} '= 1;']);
end
%--------------------------------------------------------------------------
con     = f_connexion('elem_type','tet');
nbNo_inEl = con.nbNo_inEl;
nbNo_inEd = con.nbNo_inEd;
nbNo_inFa = con.nbNo_inFa;
nbEd_inFa = con.nbEd_inFa;
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
EdNo_inEl = con.EdNo_inEl;
siNo_inEd = con.siNo_inEd;
FaNo_inEl = con.FaNo_inEl;
EdNo_inFa = con.EdNo_inFa;
FaEd_inEl = con.FaEd_inEl;
siFa_inEl = con.siFa_inEl;
siEd_inFa = con.siEd_inFa;

%--------------------------------------------------------------------------
nbNode = size(node,2);
nbElem = size(elem,2);
%--------------------------------------------------------------------------
mesh.node   = node;
if size(elem,1) <= nbNo_inEl
    elem   = [elem; ones(1,nbElem)];
end
mesh.elem   = elem;
mesh.nbNode = nbNode;
mesh.nbElem = nbElem;

%----- edges
e   = zeros(nbEd_inEl,nbNo_inEd,nbElem);
for i = 1:nbEd_inEl
    e(i,:,:) = [elem(EdNo_inEl(i,1),:); elem(EdNo_inEl(i,2),:)];
    e(i,:,:) = sort(squeeze(e(i,:,:))); % !!!
    %sie(i,:) = siedge(i) .* diff(ie);
end

edge = [];
for i = 1:nbEd_inEl
    edge = [edge squeeze(e(i,:,:))];
end
edge     = f_unique(edge,'urow');
nbEdge   = length(edge(1,:));


elem_edge = zeros(nbEd_inEl,nbElem);
for i = 1:nbEd_inEl
    elem_edge(i,:) = f_findVec('vref',edge,'vin',squeeze(e(i,:,:)));
end


%----- out
if nargin == 1 | isfield(datin,'full') | isfield(datin,'edge') 
    %----- out
    mesh.edge       = edge;
    mesh.nbEdge     = nbEdge;
    mesh.elem_edge  = elem_edge;
end


%----- faces
f   = zeros(nbFa_inEl,nbNo_inFa,nbElem);
sif = zeros(nbFa_inEl,nbElem);
celem = f_barrycenter('elem',elem,'node',node,'dim',3,'nbVertices',4);
for i = 1:nbFa_inEl
    ft = [];
    for j = 1:nbNo_inFa
        ft = [ft; elem(FaNo_inEl(i,j),:)]; 
    end
    ft = sort(ft); % must be sorted correctly
    f(i,:,:) = ft;
    cface = f_barrycenter('elem',ft,'node',node,'dim',3,'nbVertices',3);
    sif(i,:) = sign(f_dot(cface-celem,f_chavec(node,ft,'face')));
end

%-----
face = [];
for i = 1:nbFa_inEl
    face = [face squeeze(f(i,:,:))];
end
face = f_unique(face,'urow');
nbFace = length(face(1,:));

%-----
elem_face = zeros(nbFa_inEl,nbElem);
for i = 1:nbFa_inEl
    elem_face(i,:) = f_findVec('vref',face,'vin',squeeze(f(i,:,:)));
end
%-----
face_elemO = zeros(1,nbFace); % !!! convention
for i = 1:nbFa_inEl
    face_elemO(elem_face(i,sif(i,:) > 0)) = find(sif(i,:) > 0);
end
%-----
face_domO = zeros(1,nbFace);
face_domO(face_elemO > 0) = elem(nbNo_inEl+1,face_elemO(face_elemO > 0));
%-----
face_elemI = zeros(1,nbFace);
for i = 1:nbFa_inEl
    face_elemI(elem_face(i,sif(i,:) < 0)) = find(sif(i,:) < 0);
end
%-----
face_domI = zeros(1,nbFace);
face_domI(face_elemI > 0) = elem(nbNo_inEl+1,face_elemI(face_elemI > 0));

%----- face_edge
fe = zeros(nbEd_inFa,nbNo_inEd,nbFace);
sife = zeros(nbEd_inFa,nbFace);
for i = 1:nbEd_inFa
    fet = [];
    for j = 1:nbNo_inEd
        fet = [fet; face(EdNo_inFa(i,j),:)];
    end
    fe(i,:,:) = fet;
    sife(i,:) = siEd_inFa(i) .* sign(fet(2,:)-fet(1,:));
end

face_edge = zeros(nbEd_inFa,nbFace);
for i = 1:nbEd_inFa
    face_edge(i,:) = f_findVec('vref',edge,'vin',squeeze(fe(i,:,:)));
end


if nargin == 2 | isfield(datin,'full') | isfield(datin,'face') 
    %----- out
    mesh.face       = face;
    mesh.elem_face  = elem_face;
    mesh.nbFace = nbFace;
    mesh.face_elemO = face_elemO;
    mesh.face_elemI = face_elemI;
    mesh.face_domO  = face_domO;
    mesh.face_domI  = face_domI;
    mesh.face_edge  = face_edge;
end

%----- bound
if nargin == 2 | isfield(datin,'full') | isfield(datin,'bound') 
    iDom = unique(elem(nbNo_inEl+1,:));
    nb2D = length(iDom);
    ibO = []; ibI = [];
    for i = 1:nb2D
        ibO = [ibO find(face_domO == iDom(i) & face_domI == 0)];
        ibI = [ibI find(face_domI == iDom(i) & face_domO == 0)];
    end
    nbBou = length([ibO ibI]);
    bound = zeros(nbNo_inFa+1,nbBou);
    bound(1:nbNo_inFa,:) = [face(:,ibO) f_invori(face(:,ibI))];
    bound(end,:) = [ibO ibI];
    %----- out
    mesh.bound = bound;
end

%----- interface
if nargin == 2 | isfield(datin,'full') | isfield(datin,'interedge') 
    iDom = unique(elem(nbNo_inEl+1,:));
    iDom = combnk(iDom,2);
    nb2D = size(iDom,1);
    iinf = [];
    for i = 1:nb2D
        iinf = [iinf find((face_domO == iDom(i,1) & face_domI == iDom(i,2)) | ...
                          (face_domI == iDom(i,1) & face_domO == iDom(i,2)))];
    end
    nbInt = length(iinf);
    interface = zeros(nbNo_inFa+3,nbInt);
    interface(1:nbNo_inFa,:) = face(1:nbNo_inFa,iinf);
    interface(nbNo_inFa+1,:) = face_domO(iinf);
    interface(nbNo_inFa+2,:) = face_domI(iinf);
    interface(nbNo_inFa+3,:) = iinf;
    %----- out
    mesh.interface = interface;
end

%----- D, R, G
if nargin == 2 | isfield(datin,'full') | isfield(datin,'D') 
    D = sparse(nbFace,nbElem);
    for i = 1:nbFa_inEl
        D = D + sparse(elem_face(i,:),1:nbElem,sif(i,:),nbFace,nbElem);
    end
    %----- out
    mesh.D = D;
end

if nargin == 2 | isfield(datin,'full') | isfield(datin,'R') 
    R = sparse(nbEdge,nbFace);
    for i = 1:nbEd_inFa
        R = R + sparse(face_edge(i,:),1:nbFace,sife(i,:),nbEdge,nbFace);
    end
    %----- out
    mesh.R = R;
end

% sin = zeros(nbNopEd,nbEdge);
% ie  = sign(edge(2,:)-edge(1,:));
% for i = 1:nbNopEd
%     sin(i,:) = sinode(i) .* ie;
% end

if nargin == 2 | isfield(datin,'full') | isfield(datin,'G') 
    G = sparse(nbNode,nbEdge);
    for i = 1:nbNo_inEd
        G = G + sparse(edge(i,:),1:nbEdge,siNo_inEd(i),nbNode,nbEdge);
    end
    %----- out
    mesh.G = G;
end


end