function mesh = f_mdsprism(node,elem,varargin)
%--------------------------------------------------------------------------
% mesh = f_MDS69(node,elem)
% mesh = f_MDS69(node,elem,'full')
% mesh = f_MDS69(node,elem,'edge','face','interface','bound','D','R','G')
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

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','full','edge','face','bound','interface','D','G','R'};

if nargin > 2
    for i = 1:nargin-2
        if any(strcmpi(arglist,varargin{i}))
            datin.(lower(varargin{i})) = 1;
        else
            error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
        end
    end
else
    datin.full = 1;
end
%--------------------------------------------------------------------------

con       = f_connexion('prism');
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
mesh.elem        = elem;
mesh.elem_type   = 'prism';
mesh.nbNode      = nbNode;
mesh.nbElem      = nbElem;

%----- barrycenter
mesh.cnode(1,:) = mean(reshape(mesh.node(1,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
mesh.cnode(2,:) = mean(reshape(mesh.node(2,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
mesh.cnode(3,:) = mean(reshape(mesh.node(3,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));

%--------------------------------------------------------------------------
%----- edges
e = zeros(nbEd_inEl,nbNo_inEd,nbElem);
si_ori_edge_in_elem = zeros(nbEd_inEl,nbElem);
for i = 1:nbEd_inEl
    e(i,:,:) = [elem(EdNo_inEl(i,1),:); elem(EdNo_inEl(i,2),:)];
    si_ori_edge_in_elem(i,:) = sign(diff([elem(EdNo_inEl(i,1),:); elem(EdNo_inEl(i,2),:)]));
    e(i,:,:) = sort(squeeze(e(i,:,:))); % !!!
    %sie(i,:) = siedge(i) .* diff(ie);
end

edge = [];
if nbElem == 1
    edge = e.';
else
    for i = 1:nbEd_inEl
        edge = [edge squeeze(e(i,:,:))];
    end
end

edge   = f_unique(edge,'urow');
nbEdge = length(edge(1,:));

edge_in_elem = zeros(nbEd_inEl,nbElem);

if nbElem == 1
    for i = 1:nbEd_inEl
        edge_in_elem(i,:) = f_findvec(e(i,:).',edge);
    end
else
    for i = 1:nbEd_inEl
        edge_in_elem(i,:) = f_findvec(squeeze(e(i,:,:)),edge);
    end
end

%----- out
if nargin == 2 | isfield(datin,'full') | isfield(datin,'edge') 
    %----- out
    mesh.edge   = edge;
    mesh.nbEdge = nbEdge;
    mesh.edge_in_elem = edge_in_elem;
    mesh.si_ori_edge_in_elem = si_ori_edge_in_elem;
end

%--------------------------------------------------------------------------
%----- faces
maxnbNo_inFa = max(nbNo_inFa);
f = zeros(nbFa_inEl,maxnbNo_inFa,nbElem);
si_face_in_elem = zeros(nbFa_inEl,nbElem);
celem = f_barrycenter(node,elem,'dim',3,'nb_vertices',4);
for i = 1:nbFa_inEl
    ft = [];
    for j = 1:nbNo_inFa(i)
        ft = [ft; elem(FaNo_inEl(i,j),:)]; 
    end
    [ft,si_ori] = f_sortori(ft);
    ft = [ft; zeros(maxnbNo_inFa-nbNo_inFa(i),nbElem)];
    f(i,:,:) = ft;
    cface = f_barrycenter(node,ft,'dim',3,'nb_vertices',nbNo_inFa(i));
    si_face_in_elem(i,:) = sign(f_dot(cface-celem,f_chavec(node,ft,'face')));
    si_ori_face_in_elem(i,:) = si_ori;
end

%-----
face = [];
if nbElem == 1
    face = f.';
else
    for i = 1:nbFa_inEl
        face = [face squeeze(f(i,:,:))];
    end
end
face = f_unique(face,'urow');
nbFace = length(face(1,:));

%-----
face_in_elem = zeros(nbFa_inEl,nbElem);
if nbElem == 1
    for i = 1:nbFa_inEl
        face_in_elem(i,:) = f_findvec(f(i,:).',face);
    end
else
    for i = 1:nbFa_inEl
        face_in_elem(i,:) = f_findvec(squeeze(f(i,:,:)),face);
    end
end

%-----
elemL_of_face = zeros(1,nbFace); % !!! convention
for i = 1:nbFa_inEl
    elemL_of_face(face_in_elem(i,si_face_in_elem(i,:) > 0)) = find(si_face_in_elem(i,:) > 0);
end
%-----
domL_of_face = zeros(1,nbFace);
domL_of_face(elemL_of_face > 0) = elem(nbNo_inEl+1,elemL_of_face(elemL_of_face > 0));
%-----
elemR_of_face = zeros(1,nbFace);
for i = 1:nbFa_inEl
    elemR_of_face(face_in_elem(i,si_face_in_elem(i,:) < 0)) = find(si_face_in_elem(i,:) < 0);
end
%-----
domR_of_face = zeros(1,nbFace);
domR_of_face(elemR_of_face > 0) = elem(nbNo_inEl+1,elemR_of_face(elemR_of_face > 0));

%----- face_edge
maxnbEd_inFa = max(cell2mat(nbEd_inFa));
fe = zeros(maxnbEd_inFa,nbNo_inEd,nbFace);
si_edge_in_face = zeros(maxnbEd_inFa,nbFace);

itria = find(face(4,:) == 0);
iquad = setdiff(1:nbFace,itria);

for k = 1:2 %---- 2 faceType
    switch k
        case 1
            iface = itria;
        case 2
            iface = iquad;
    end
    for i = 1:nbEd_inFa{k}
        fet = [];
        for j = 1:nbNo_inEd
            fet = [fet; face(EdNo_inFa{k}(i,j),iface)];
        end
        fe(i,:,iface) = fet;
        si_edge_in_face(i,iface) = siEd_inFa{k}(i) .* sign(fet(2,:)-fet(1,:));
    end
end

%--------------------------------------------------------------------------

edge_in_face = zeros(maxnbEd_inFa,nbFace);
for i = 1:maxnbEd_inFa
    edge_in_face(i,:) = f_findvec(squeeze(fe(i,:,:)),edge);
end
edge_in_face(isnan(edge_in_face)) = 0;

%--------------------------------------------------------------------------
if nargin == 2 | isfield(datin,'full') | isfield(datin,'face') 
    %----- out
    mesh.face       = face;
    mesh.nbFace     = nbFace;
    mesh.face_in_elem  = face_in_elem;
    mesh.elemL_of_face = elemL_of_face;
    mesh.elemR_of_face = elemR_of_face;
    mesh.domL_of_face  = domL_of_face;
    mesh.domR_of_face  = domR_of_face;
    mesh.edge_in_face  = edge_in_face;
    mesh.si_edge_in_face = si_edge_in_face;
    mesh.si_face_in_elem = si_face_in_elem;
    mesh.si_ori_face_in_elem = si_ori_face_in_elem;
end

%----- bound
%----- with outward normal
if nargin == 2 | isfield(datin,'full') | isfield(datin,'bound') 
    iDom = unique(elem(nbNo_inEl+1,:));
    nb2D = length(iDom);
    ibO = []; ibI = [];
    for i = 1:nb2D
        ibO = [ibO find(domL_of_face == iDom(i) & domR_of_face == 0)];
        ibI = [ibI find(domR_of_face == iDom(i) & domL_of_face == 0)];
    end
    nbBou = length([ibO ibI]);
    bound = zeros(maxnbNo_inFa+1,nbBou);
    bound(1:maxnbNo_inFa,:) = [face(:,ibO) f_invori(face(:,ibI))];
    bound(end,:) = [ibO ibI];
    %----- out
    mesh.bound = bound;
end

%----- interface
if nargin == 2 | isfield(datin,'full') | isfield(datin,'interface') 
    iDom = unique(elem(nbNo_inEl+1,:));
    iDom = combnk(iDom,2);
    nb2D = size(iDom,1);
    iinf = [];
    for i = 1:nb2D
        iinf = [iinf find((domL_of_face == iDom(i,1) & domR_of_face == iDom(i,2)) | ...
                          (domR_of_face == iDom(i,1) & domL_of_face == iDom(i,2)))];
    end
    nbInt = length(iinf);
    if ~isempty(iinf)
        interface = zeros(maxnbNo_inFa+3,nbInt);
        interface(1:maxnbNo_inFa,:) = face(1:maxnbNo_inFa,iinf);
        interface(maxnbNo_inFa+1,:) = domL_of_face(iinf);
        interface(maxnbNo_inFa+2,:) = domR_of_face(iinf);
        interface(maxnbNo_inFa+3,:) = iinf;
        %----- out
        mesh.interface = interface;
    else
        mesh.interface = [];
    end
end

%----- D, R, G
%----- D
if nargin == 2 | isfield(datin,'full') | isfield(datin,'D') 
    D = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        D = D + sparse(1:nbElem,face_in_elem(i,:),si_face_in_elem(i,:),nbElem,nbFace);
    end
    %----- out
    mesh.D = D;
end
%----- R
if nargin == 2 | isfield(datin,'full') | isfield(datin,'R') 
    R = sparse(nbFace,nbEdge);
    for k = 1:2 %---- 2 faceType
        switch k
            case 1
                iface = itria;
            case 2
                iface = iquad;
        end
        for i = 1:nbEd_inFa{k}
            R = R + sparse(iface,edge_in_face(i,iface),si_edge_in_face(i,iface),nbFace,nbEdge);
        end
    end
    %----- out
    mesh.R = R;
end

%----- G
if nargin == 2 | isfield(datin,'full') | isfield(datin,'G') 
    G = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        G = G + sparse(1:nbEdge,edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
    %----- out
    mesh.G = G;
end

end