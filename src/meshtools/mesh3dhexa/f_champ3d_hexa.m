function geo = f_champ3d_hexa(geo,varargin)
% F_CHAMP3D_HEXA ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_layer','id_mesh3d','mesher'};

% --- default input value
id_mesh2d = [];
id_layer  = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh2d)
    error([mfilename ' : #id_mesh2d must be given !']);
end
if isempty(id_layer)
    error([mfilename ' : #id_layer must be given !']);
end
%--------------------------------------------------------------------------
while iscell(id_mesh2d)
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
tic;
fprintf('Making hexa mesh3d  ... ');

%--------------------------------------------------------------------------
divlay   = [];
nb_layer = 0;
IDLayer  = [];
for i = 1:length(id_layer)
    %-----
    divlay_i = f_div1d(geo.geo1d.layer.(id_layer{i}));
    divlay   = [divlay divlay_i];
    %-----
    nbL = length(divlay_i);
    nb_layer = nb_layer + nbL;
    %-----
    id = [];
    for j = 1:nbL
        id{j} = id_layer{i};
    end
    %-----
    IDLayer = [IDLayer id];
end
%--------------------------------------------------------------------------
codeidl = f_str2code(IDLayer);

%--------------------------------------------------------------------------
% build vertices (nodes) in 3D

nbNode2D = geo.geo2d.mesh2d.(id_mesh2d).nb_node;
nb_node  = nbNode2D*(nb_layer+1);
node = zeros(3,nb_node);
node(1:2,:) = repmat(geo.geo2d.mesh2d.(id_mesh2d).node,1,nb_layer+1);
for i = 1:nb_layer
   node(3,i*nbNode2D+1:(i+1)*nbNode2D) = sum(divlay(1:i)) .* ones(1,nbNode2D);
end

%--------------------------------------------------------------------------
% build volume elements (elem) in 3D
nbElem2D = geo.geo2d.mesh2d.(id_mesh2d).nb_elem;
nb_elem = nbElem2D * nb_layer;
elem = zeros(8, nb_elem);
elem_code = zeros(1, nb_elem);

ie0 = 0;
for k = 1:nb_layer	% k : current layer
    % lower face
    elem(1,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(1,:) + nbNode2D * (k-1);
    elem(2,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(2,:) + nbNode2D * (k-1);
    elem(3,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(3,:) + nbNode2D * (k-1);
    elem(4,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(4,:) + nbNode2D * (k-1);
    % upper face
    elem(5,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(1,:) + nbNode2D * k;
    elem(6,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(2,:) + nbNode2D * k;
    elem(7,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(3,:) + nbNode2D * k;
    elem(8,ie0+1 : ie0+nbElem2D) = geo.geo2d.mesh2d.(id_mesh2d).elem(4,:) + nbNode2D * k;
    % elem code --> encoded id (id_x, id_y, id_layer)
    elem_code(1,ie0+1 : ie0+nbElem2D)  = geo.geo2d.mesh2d.(id_mesh2d).elem_code * codeidl(k);
    % go to the next layer
    ie0 = ie0 + nbElem2D;
end

%--------------------------------------------------------------------------
% --- Output
geo.geo3d.mesh3d.(id_mesh3d).node = node;
geo.geo3d.mesh3d.(id_mesh3d).nb_node = nb_node;
geo.geo3d.mesh3d.(id_mesh3d).elem = elem;
geo.geo3d.mesh3d.(id_mesh3d).nb_elem = nb_elem;
geo.geo3d.mesh3d.(id_mesh3d).elem_code = elem_code;
geo.geo3d.mesh3d.(id_mesh3d).elem_type = 'hexa';
% ---
% for i = 1:lenx
%     mesh2d.(id_x{i}).id_elem = all_id_elem(elem_code == i);
% end
% for i = 1:leny
%     mesh2d.(id_y{i}).id_elem = all_id_elem(idy_elem == i);
% end
% ---
geo.geo3d.mesh3d.(id_mesh3d).cnode(1,:) = mean(reshape(node(1,elem(1:8,:)),8,nb_elem));
geo.geo3d.mesh3d.(id_mesh3d).cnode(2,:) = mean(reshape(node(2,elem(1:8,:)),8,nb_elem));
geo.geo3d.mesh3d.(id_mesh3d).cnode(3,:) = mean(reshape(node(3,elem(1:8,:)),8,nb_elem));
% ---
%mesh = f_mdshexa(node,elem,'full');

% --- Log message
fprintf('done ----- in %.2f s \n',toc);




