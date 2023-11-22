function shape2d = f_pdetool2d(shape2d,varargin)
% F_PDETOOL2D ...
%--------------------------------------------------------------------------
% dom2D = f_pdetool2DMatlab(dom2D,'mesh_type','simple')
% dom2D = f_pdetool2DMatlab(dom2D,'mesh_type','full')
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------
shape2d.mesher = 'pdetool2d';

if isfield(shape2d,'geoIn')
    switch shape2d.geoIn.type
        case 'geofromdom'
            dgeo = decsg(shape2d.geoIn.geo,['(' shape2d.geoIn.form ')'],shape2d.geoIn.dName.');
        case 'geofromedge'
            dgeo = shape2d.geoIn.dgeo;
    end
else
    error([mfilename ': dom2D geometry input is not defined!']);
end

%-----
datin = [];
if nargin > 1
    %-----
    hgrad = 1.3;
    box  = 'off';
    init = 'off';
    jiggle = 'mean';
    jiggleiter = 10;
    mesherversion = 'R2013a';

    for i = 1:nargin/2
        (lower(varargin{2*i-1})) = varargin{2*i};
    end
    if isfield(datin,'hmax')
        [node,eb,elem]=initmesh(dgeo,'Hgrad',hgrad,'Hmax',hmax,'Box',box,...
                                 'Init',init,'Jiggle',jiggle,...
                                 'JiggleIter',jiggleiter,'MesherVersion',mesherversion);
    else
        [node,eb,elem]=initmesh(dgeo,'Hgrad',hgrad,'Box',box,...
                                 'Init',init,'Jiggle',jiggle,...
                                 'JiggleIter',jiggleiter,'MesherVersion',mesherversion);
    end
else
    shape2d.mesh_type = 'simple';
    [node,eb,elem]=initmesh(dgeo);
end

%----- check and correct mesh
[node,elem]=f_reorg2d(node,elem);
%--------------------------------------------------------------------------
shape2d.mesh.dgeo = dgeo;
shape2d.mesh.node = node;  shape2d.mesh.nbNode = size(shape2d.mesh.node,2);
shape2d.mesh.elem = elem;  shape2d.mesh.nbElem = size(shape2d.mesh.elem,2);
shape2d.mesh.eb   = eb; % bound edge defined by initmesh tool
shape2d.mesh.elem_type = 'tri';
shape2d.dName  = unique(elem(4,:));
shape2d.nbDom  = length(shape2d.dName);

end
