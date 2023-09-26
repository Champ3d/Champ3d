function c3dobj = f_c3d_prismmesh(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_layer','id_mesh3d','mesher'};

% --- default input value
id_mesh3d = [];
id_mesh2d = [];
id_mesh1d = [];
id_layer  = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh2d)
    error([mfilename ' : #id_mesh2d must be given !']);
end
%--------------------------------------------------------------------------
while iscell(id_mesh2d)
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
if isempty(id_layer)
    error([mfilename ' : #id_layer must be given !']);
end
%--------------------------------------------------------------------------
if ~iscell(id_layer)
    idl = id_layer;
    id_layer = {};
    id_layer{1} = idl;
end
%--------------------------------------------------------------------------
if isempty(id_mesh1d)
    id_mesh1d = fieldnames(c3dobj.mesh1d);
    id_mesh1d = id_mesh1d{1};
end
%--------------------------------------------------------------------------
tic;
fprintf(['Make c3d_prismmesh #' id_mesh3d]);

%--------------------------------------------------------------------------
divlay   = [];
nb_layer = 0;
IDLayer  = [];
for i = 1:length(id_layer)
    %-----
    divlay_i = f_div1d(c3dobj.mesh1d.(id_mesh1d).layer.(id_layer{i}));
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

nbNode2D = c3dobj.mesh2d.(id_mesh2d).nb_node;
nb_node  = nbNode2D*(nb_layer+1);
node = zeros(3,nb_node);
node(1:2,:) = repmat(c3dobj.mesh2d.(id_mesh2d).node,1,nb_layer+1);
for i = 1:nb_layer
   node(3,i*nbNode2D+1:(i+1)*nbNode2D) = sum(divlay(1:i)) .* ones(1,nbNode2D);
end

%--------------------------------------------------------------------------
% build volume elements (elem) in 3D
nbElem2D = c3dobj.mesh2d.(id_mesh2d).nb_elem;
nb_elem = nbElem2D * nb_layer;
elem = zeros(6, nb_elem);
elem_code = zeros(1, nb_elem);

% ---
elem2d = [c3dobj.mesh2d.(id_mesh2d).elem(1,:); ...
          c3dobj.mesh2d.(id_mesh2d).elem(2,:); ...
          c3dobj.mesh2d.(id_mesh2d).elem(3,:)];
% ---
ie0 = 0;
for k = 1:nb_layer	% k : current layer
    % ---------------------------------------------------------------------
    elem(1:3,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D * (k-1);
    elem(4:6,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D *  k;
    % ---------------------------------------------------------------------
    % elem code --> encoded id (id_x, id_y, id_layer)
    elem_code(1,ie0+1 : ie0+nbElem2D)  = c3dobj.mesh2d.(id_mesh2d).elem_code * codeidl(k);
    % go to the next layer
    ie0 = ie0 + nbElem2D;
end

%--------------------------------------------------------------------------
% --- Output
c3dobj.mesh3d.(id_mesh3d).mesher = 'c3d_prismmesh';
c3dobj.mesh3d.(id_mesh3d).id_mesh2d = id_mesh2d;
c3dobj.mesh3d.(id_mesh3d).id_mesh1d = id_mesh1d;
c3dobj.mesh3d.(id_mesh3d).node = node;
c3dobj.mesh3d.(id_mesh3d).nb_node = nb_node;
c3dobj.mesh3d.(id_mesh3d).elem = elem;
c3dobj.mesh3d.(id_mesh3d).nb_elem = nb_elem;
c3dobj.mesh3d.(id_mesh3d).elem_code = elem_code;
c3dobj.mesh3d.(id_mesh3d).elem_type = 'prism';
%--------------------------------------------------------------------------
cnode = mean(reshape(node(:,elem(1:6,:)),3,6,nb_elem),2);
c3dobj.mesh3d.(id_mesh3d).cnode = squeeze(cnode);
%--------------------------------------------------------------------------
c3dobj.mesh3d.(id_mesh3d).edge = f_edge(c3dobj.mesh3d.(id_mesh3d).elem, ...
                            'elem_type',c3dobj.mesh3d.(id_mesh3d).elem_type);
c3dobj.mesh3d.(id_mesh3d).face = f_face(c3dobj.mesh3d.(id_mesh3d).elem, ...
                            'elem_type',c3dobj.mesh3d.(id_mesh3d).elem_type);
%--------------------------------------------------------------------------
% --- Log message
fprintf(' --- in %.2f s \n',toc);




