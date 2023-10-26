function dom2d = f_refine2d(dom2d,varargin)
% F_REFINE2D return dom2D with refined mesh in specified regions.
% dom2D.mesh = f_REFINE2D(dom2D.mesh,'dom2refine',[2 5]);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

tic
fprintf('Refining 2D mesh ... ');

datin = [];

for i = 1:length(varargin)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

datin = f_addtostruct(dom2d.mesher_option,datin);

if isfield(datin,'dom2refine')
%     [node,bound,elem] = initmesh(dom2d.mesh.dgeo,'Hgrad',datin.hgrad,'Hmax',datin.hmax,'Box',datin.box,...
%                               'Init',datin.init,'Jiggle',datin.jiggle,...
%                               'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
    node = dom2d.mesh.node;
    bound = dom2d.mesh.eb;
    elem = dom2d.mesh.elem;
    for i= 1:length(datin.dom2refine)
        dom2refine = datin.dom2refine(i);
        [node,bound,elem] = refinemesh(dom2d.mesh.dgeo,node,bound,elem,dom2refine);
    end
    %----- check and correct mesh
    [node,elem]=f_reorg2d(node,elem);
    %--------------------------------------------------------------------------
    dom2d.mesh.node = node;  dom2d.mesh.nbNode = size(dom2d.mesh.node,2);
    dom2d.mesh.elem = elem;  dom2d.mesh.nbElem = size(dom2d.mesh.elem,2);
    dom2d.mesh.elem_type = 33.*ones(1,dom2d.mesh.nbElem);
    dom2d.mesh.elem_dom  = elem(4,:);
    dom2d.dName  = unique(elem(4,:));
    dom2d.nbDom  = length(dom2d.dName);
    %----- edges --------------------------------------------------------------
    nbElem = size(elem,2);
    e1 = [elem(1,:); elem(2,:)]; [e1,ie1] = sort(e1); sie1 = +diff(ie1);
    e2 = [elem(1,:); elem(3,:)]; [e2,ie2] = sort(e2); sie2 = -diff(ie2); % !!!
    e3 = [elem(2,:); elem(3,:)]; [e3,ie3] = sort(e3); sie3 = +diff(ie3);
    edge = [e1 e2 e3];
    edge     = f_unique(edge,'urow');
    nbEdge   = length(edge(1,:));
    elem_edge = zeros(3,nbElem);
    elem_edge(1,:) = f_findvec(e1,edge);
    elem_edge(2,:) = f_findvec(e2,edge);
    elem_edge(3,:) = f_findvec(e3,edge);
    edge_elemL = zeros(1,nbEdge);
    edge_elemL(elem_edge(1,sie1 > 0)) = find(sie1 > 0);
    edge_elemL(elem_edge(2,sie2 > 0)) = find(sie2 > 0);
    edge_elemL(elem_edge(3,sie3 > 0)) = find(sie3 > 0);
    edge_domL = zeros(1,nbEdge);
    edge_domL(edge_elemL > 0) = elem(4,edge_elemL(edge_elemL > 0));
    edge_elemR = zeros(1,nbEdge);
    edge_elemR(elem_edge(1,sie1 < 0)) = find(sie1 < 0);
    edge_elemR(elem_edge(2,sie2 < 0)) = find(sie2 < 0);
    edge_elemR(elem_edge(3,sie3 < 0)) = find(sie3 < 0);
    edge_domR = zeros(1,nbEdge);
    edge_domR(edge_elemR > 0) = elem(4,edge_elemR(edge_elemR > 0));
    %----- bound --------------------------------------------------------------
    iDom = unique(elem(4,:));
    iDom = combnk(iDom,2);
    nb2D = size(iDom,1);
    bound = [];
    for i = 1:nb2D
        bound = [bound find((edge_domL == iDom(i,1) & edge_domR == iDom(i,2)) | ...
                            (edge_domR == iDom(i,1) & edge_domL == iDom(i,2)))];
    end
    dom2d.mesh.bound = bound; %dom2D.mesh.nbb = size(dom2D.mesh.b,2);
    %--------------------------------------------------------------------------
    if strcmpi(dom2d.mesh_type,'full')
        %fmesh = f_fullmesh2D(dom2D.mesh.node,dom2D.mesh.elem,'tri');
        fmesh = f_mdstri(dom2d.mesh.node,dom2d.mesh.elem,'full');
        dom2d.mesh = f_addtostruct(fmesh,dom2d.mesh);
    end
end

fprintf('%.4f s \n',toc);

end