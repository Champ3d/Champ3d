function mesh = f_mdstri(node,elem,varargin)
% F_MDSTRI returns ...
%--------------------------------------------------------------------------
% TODO : 
% + interface
%--------------------------------------------------------------------------
% mesh = F_MDSTRI(node,elem)
% mesh = F_MDSTRI(node,elem,'full')
% mesh = F_MDSTRI(node,elem,'edge','face','interface','interedge','bound','D','R','G')
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'node','elem','full','edge','face','bound','interedge','D','G','R'};

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
con       = f_connexion('tri');
nbNo_inEl = con.nbNo_inEl;
nbNo_inEd = con.nbNo_inEd;
nbNo_inFa = con.nbNo_inFa;
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
EdNo_inEl = con.EdNo_inEl;
siNo_inEd = con.siNo_inEd;
siEd_inEl = con.siEd_inEl;
FaNo_inEl = con.FaNo_inEl;
siFa_inEl = con.siFa_inEl;
%--------------------------------------------------------------------------
% nbNode = max(elem(1,:));
% for i = 2:nbNopEl
%     nbNode = max([nbNode max(elem(i,:))]);
% end
nbNode = size(node,2);
nbElem = size(elem,2);
%--------------------------------------------------------------------------
mesh.node   = node;
if size(elem,1) <= nbNo_inEl
    elem   = [elem; ones(1,nbElem)];
end
mesh.elem      = elem;
mesh.elem_type = 'tri';
mesh.nbNode = nbNode;
mesh.nbElem = nbElem;

%----- barrycenter
mesh.cnode(1,:) = mean(reshape(mesh.node(1,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
mesh.cnode(2,:) = mean(reshape(mesh.node(2,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
%----- area
mesh.elem_size  = polyarea(reshape(mesh.node(1,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem),...
                           reshape(mesh.node(2,mesh.elem(1:nbNo_inEl,:)),nbNo_inEl,nbElem));
                       
%----- edges
e   = zeros(nbEd_inEl,nbNo_inEd,nbElem);
si_edge_in_elem = zeros(nbEd_inEl,nbElem);
for i = 1:nbEd_inEl
    e(i,:,:) = [elem(EdNo_inEl(i,1),:); elem(EdNo_inEl(i,2),:)];
    [e(i,:,:), ie] = sort(squeeze(e(i,:,:)));
    si_edge_in_elem(i,:) = siEd_inEl(i) .* diff(ie);
    si_ori_edge_in_elem(i,:) = diff(ie);
end


edge = [];
for i = 1:nbEd_inEl
    edge = [edge squeeze(e(i,:,:))];
end
edge     = f_unique(edge,'urow');
nbEdge   = length(edge(1,:));


edge_in_elem = zeros(nbEd_inEl,nbElem);
for i = 1:nbEd_inEl
    edge_in_elem(i,:) = f_findvec(squeeze(e(i,:,:)),edge);
end

elemL_of_edge = zeros(1,nbEdge);
for i = 1:nbEd_inEl
    elemL_of_edge(edge_in_elem(i,si_edge_in_elem(i,:) > 0)) = find(si_edge_in_elem(i,:) > 0);
end

domL_of_edge = zeros(1,nbEdge);
domL_of_edge(elemL_of_edge > 0) = elem(nbNo_inEl+1,elemL_of_edge(elemL_of_edge > 0));


elemR_of_edge = zeros(1,nbEdge);
for i = 1:nbEd_inEl
    elemR_of_edge(edge_in_elem(i,si_edge_in_elem(i,:) < 0)) = find(si_edge_in_elem(i,:) < 0);
end

domR_of_edge = zeros(1,nbEdge);
domR_of_edge(elemR_of_edge > 0) = elem(nbNo_inEl+1,elemR_of_edge(elemR_of_edge > 0));

%----- out
if isfield(datin,'full') | isfield(datin,'edge') 
    %----- out
    mesh.edge       = edge;
    mesh.nbEdge     = nbEdge;
    mesh.edge_in_elem  = edge_in_elem;
    mesh.elemL_of_edge = elemL_of_edge;
    mesh.domL_of_edge  = domL_of_edge;
    mesh.elemR_of_edge = elemR_of_edge;
    mesh.domR_of_edge  = domR_of_edge;
    mesh.si_edge_in_elem = si_edge_in_elem;
    mesh.si_ori_edge_in_elem = si_ori_edge_in_elem;
end

%----- interedge
if isfield(datin,'full') | isfield(datin,'interedge') 
    iDom = unique(elem(nbNo_inEl+1,:));
    iDom = combnk(iDom,2);
    nb2D = size(iDom,1);
    iine = [];
    for i = 1:nb2D
        iine = [iine find((domL_of_edge == iDom(i,1) & domR_of_edge == iDom(i,2)) | ...
                          (domR_of_edge == iDom(i,1) & domL_of_edge == iDom(i,2)))];
    end
    nbInt = length(iine);
    if ~isempty(iine)
        interedge = zeros(5,nbInt);
        interedge(1,:) = edge(1,iine);
        interedge(2,:) = edge(2,iine);
        interedge(3,:) = domL_of_edge(iine);
        interedge(4,:) = domR_of_edge(iine);
        interedge(5,:) = iine;
        %----- out
        mesh.interedge = interedge;
    end
end


%----- bound
if isfield(datin,'full') | isfield(datin,'bound') 
    iDom = unique(elem(nbNo_inEl+1,:));
    nb2D = length(iDom);
    ibL = []; ibR = [];
    for i = 1:nb2D
        ibL = [ibL find(domL_of_edge == iDom(i) & domR_of_edge == 0)];
        ibR = [ibR find(domR_of_edge == iDom(i) & domL_of_edge == 0)];
    end
    nbBou = length([ibL ibR]);
    bound = zeros(3,nbBou);
    bound(1,:) = [edge(1,ibL) edge(2,ibR)];
    bound(2,:) = [edge(2,ibL) edge(1,ibR)];
    bound(3,:) = [ibL ibR];
    %----- out
    mesh.bound = bound;
end


%----- faces
face          = edge;
face_in_elem  = edge_in_elem;
elemL_of_face = elemL_of_edge;
elemR_of_face = elemR_of_edge;
domL_of_face  = domL_of_edge;
domR_of_face  = domR_of_edge;
nbFace        = length(face(1,:));
si_face_in_elem  = si_edge_in_elem;
si_ori_face_in_elem = si_ori_edge_in_elem;
if isfield(datin,'full') | isfield(datin,'face') 
    %----- out
    mesh.face       = face;
    mesh.face_in_elem  = face_in_elem;
    mesh.nbFace     = nbFace;
    mesh.elemL_of_face = elemL_of_face;
    mesh.elemR_of_face = elemR_of_face;
    mesh.domL_of_face  = domL_of_face;
    mesh.domR_of_face  = domR_of_face;
    mesh.si_face_in_elem = si_face_in_elem;
    mesh.si_ori_face_in_elem = si_ori_face_in_elem;
end


%----- D, R, G
if isfield(datin,'full') | isfield(datin,'D') 
    D = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        D = D + sparse(1:nbElem,face_in_elem(i,:),si_face_in_elem(i,:),nbElem,nbFace);
    end
    %----- out
    mesh.D = D;
end

if isfield(datin,'full') | isfield(datin,'R') 
    R = sparse(nbElem,nbEdge);
    for i = 1:nbFa_inEl
        R = R + sparse(1:nbElem,face_in_elem(i,:),si_edge_in_elem(i,:),nbElem,nbEdge);
    end
    %----- out
    mesh.R = R;
end


if isfield(datin,'full') | isfield(datin,'G') 
    G = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        G = G + sparse(1:nbEdge,edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
    %----- out
    mesh.G = G;
end


end