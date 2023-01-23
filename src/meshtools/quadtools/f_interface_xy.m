function idNode = f_interface_xy(t2d,id_dom)

% method = 'by_xylim', 'by_id_xydom'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
nb_dom = length(id_dom);
allNode = cell(nb_dom);
for i = 1:nb_dom
    idElem = id_dom{i};
    allNode{i} = unique([t2d(1,idElem) t2d(2,idElem) t2d(3,idElem) t2d(4,idElem)]);
end
% ---
idNode = allNode{1};
for i = 2:nb_dom
    idNode = intersect(idNode,allNode{i});
end
idNode = unique(idNode);