function dom2d = f_pdetool2d(dom2d,varargin)
% F_PDETOOL2D ...
%--------------------------------------------------------------------------
% dom2D = f_pdetool2DMatlab(dom2D,'mesh_type','simple')
% dom2D = f_pdetool2DMatlab(dom2D,'mesh_type','full')
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
dom2d.mesher = 'pdetool2d';

if isfield(dom2d,'geoIn')
    switch dom2d.geoIn.type
        case 'geofromdom'
            dgeo = decsg(dom2d.geoIn.geo,['(' dom2d.geoIn.form ')'],dom2d.geoIn.dName.');
        case 'geofromedge'
            dgeo = dom2d.geoIn.dgeo;
    end
else
    error([mfilename ': dom2D geometry input is not defined!']);
end

%-----
datin = [];
if nargin > 1
    %-----
    %dom2D.mesh_type = datin.mesh_type;
    datin.Hgrad = 1.3;
    datin.Box  = 'off';
    datin.Init = 'off';
    datin.Jiggle = 'mean';
    datin.JiggleIter = 10;
    datin.MesherVersion = 'R2013a';
    for i = 1:nargin/2
        datin.(lower(varargin{2*i-1})) = varargin{2*i};
    end
    if isfield(datin,'hmax')
        [node,eb,elem]=initmesh(dgeo,'Hgrad',datin.hgrad,'Hmax',datin.hmax,'Box',datin.box,...
                                 'Init',datin.init,'Jiggle',datin.jiggle,...
                                 'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
    else
        [node,eb,elem]=initmesh(dgeo,'Hgrad',datin.hgrad,'Box',datin.box,...
                                 'Init',datin.init,'Jiggle',datin.jiggle,...
                                 'JiggleIter',datin.jiggleiter,'MesherVersion',datin.mesherversion);
    end
else
    dom2d.mesh_type = 'simple';
    [node,eb,elem]=initmesh(dgeo);
end

%----- check and correct mesh
[node,elem]=f_reorg2d(node,elem);
%--------------------------------------------------------------------------
dom2d.mesh.dgeo = dgeo;
dom2d.mesh.node = node;  dom2d.mesh.nbNode = size(dom2d.mesh.node,2);
dom2d.mesh.elem = elem;  dom2d.mesh.nbElem = size(dom2d.mesh.elem,2);
dom2d.mesh.eb   = eb; % bound edge defined by initmesh tool
dom2d.mesh.elem_type = 'tri';
dom2d.dName  = unique(elem(4,:));
dom2d.nbDom  = length(dom2d.dName);

if strcmpi(dom2d.mesh_type,'full')
    fmesh = f_mdstri(dom2d.mesh.node,dom2d.mesh.elem,'full');
    dom2d.mesh = f_addtostruct(fmesh,dom2d.mesh);
end

end







% %----- edges --------------------------------------------------------------
% nbElem = size(elem,2);
% e1 = [elem(1,:); elem(2,:)]; [e1,ie1] = sort(e1); sie1 = +diff(ie1);
% e2 = [elem(1,:); elem(3,:)]; [e2,ie2] = sort(e2); sie2 = -diff(ie2); % !!!
% e3 = [elem(2,:); elem(3,:)]; [e3,ie3] = sort(e3); sie3 = +diff(ie3);
% edge = [e1 e2 e3];
% edge     = f_unique(edge,'urow');
% nbEdge   = length(edge(1,:));
% elem_edge = zeros(3,nbElem);
% elem_edge(1,:) = f_findvec(e1,edge);
% elem_edge(2,:) = f_findvec(e2,edge);
% elem_edge(3,:) = f_findvec(e3,edge);
% edge_elemL = zeros(1,nbEdge);
% edge_elemL(elem_edge(1,sie1 > 0)) = find(sie1 > 0);
% edge_elemL(elem_edge(2,sie2 > 0)) = find(sie2 > 0);
% edge_elemL(elem_edge(3,sie3 > 0)) = find(sie3 > 0);
% edge_domL = zeros(1,nbEdge);
% edge_domL(edge_elemL > 0) = elem(4,edge_elemL(edge_elemL > 0));
% edge_elemR = zeros(1,nbEdge);
% edge_elemR(elem_edge(1,sie1 < 0)) = find(sie1 < 0);
% edge_elemR(elem_edge(2,sie2 < 0)) = find(sie2 < 0);
% edge_elemR(elem_edge(3,sie3 < 0)) = find(sie3 < 0);
% edge_domR = zeros(1,nbEdge);
% edge_domR(edge_elemR > 0) = elem(4,edge_elemR(edge_elemR > 0));
% %----- bound --------------------------------------------------------------
% iDom = unique(elem(4,:));
% iDom = combnk(iDom,2);
% nb2D = size(iDom,1);
% bound = [];
% for i = 1:nb2D
%     bound = [bound find((edge_domL == iDom(i,1) & edge_domR == iDom(i,2)) | ...
%                         (edge_domR == iDom(i,1) & edge_domL == iDom(i,2)))];
% end
% dom2D.mesh.bound = bound;
%--------------------------------------------------------------------------