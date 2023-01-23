function mesh = f_hexa2dto3d(dom2d,layer)
% F_PRISM2Dto3D build 3D prismatic mesh from triangle dom2D and layer
% description.
%--------------------------------------------------------------------------
% dom3D = f_prism2Dto3D(dom2D,layer)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l?Universit?, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------
% See also: f_add_layer


% dom3D.meshType = 'prism';
% dom3d.layer = layer;
% dom3d.mesh.mesher = 'hexa2dto3d';

%%
Lthickness = [];
nbLayers = 0;
IDLayer = [];
for i = 1:length(layer)
    %-----
    Lthickness = [Lthickness layer(i).thickness];
    %-----
    id = [];
    nbL = length(layer(i).thickness);
    nbLayers = nbLayers + nbL;
    for j = 1:nbL
        id{j} = layer(i).id_layer;
    end
    IDLayer = [IDLayer id];
end

codeLayer = f_str2code(IDLayer);

%%

% build vertices (node) in 3D

nbNode2D = size(dom2d.mesh.node,2);
node = zeros(3,nbNode2D*(nbLayers+1));
node(1:2,:) = repmat(dom2d.mesh.node,1,nbLayers+1);
for i = 1:nbLayers
   node(3,i*nbNode2D+1:(i+1)*nbNode2D) = sum(Lthickness(1:i)) .* ones(1,nbNode2D);
end

% dom3D.mesh.node = node;
% dom3D.mesh.nbnode = size(node,2);  % number of nodes

%%

% build volume elements (elem) in 3D
nbElem2D = size(dom2d.mesh.elem,2);
nt=0;
for k=1:nbLayers	% k : current layer
    % lower face
    elem(1,nt+1:nt+nbElem2D) = dom2d.mesh.elem(1,:) + nbNode2D * (k-1);
    elem(2,nt+1:nt+nbElem2D) = dom2d.mesh.elem(2,:) + nbNode2D * (k-1);
    elem(3,nt+1:nt+nbElem2D) = dom2d.mesh.elem(3,:) + nbNode2D * (k-1);
    elem(4,nt+1:nt+nbElem2D) = dom2d.mesh.elem(4,:) + nbNode2D * (k-1);
    % upper face
    elem(5,nt+1:nt+nbElem2D) = dom2d.mesh.elem(1,:) + nbNode2D * k;
    elem(6,nt+1:nt+nbElem2D) = dom2d.mesh.elem(2,:) + nbNode2D * k;
    elem(7,nt+1:nt+nbElem2D) = dom2d.mesh.elem(3,:) + nbNode2D * k;
    elem(8,nt+1:nt+nbElem2D) = dom2d.mesh.elem(4,:) + nbNode2D * k;
    % zone 3D
    % elem(7,nt+1:nt+nbElem2D) = dom2D.mesh.elem(4,:) + k * pi;
    elem(9,nt+1:nt+nbElem2D)  = dom2d.mesh.elem(5,:) + codeLayer(k);
    % zone 2D
    elem(10,nt+1:nt+nbElem2D) = dom2d.mesh.elem(5,:);
    % layer id
    elem(11,nt+1:nt+nbElem2D) = k;
    % go to the next zone
    nt=nt+nbElem2D;
end

mesh = f_mdshexa(node,elem,'full');


end