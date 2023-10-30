function c3dobj = f_c3d_prismmesh(c3dobj,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_layer','id_mesh3d','mesher', ...
           'centering', 'origin_coordinates'};

% --- default input value
id_mesh3d = [];
id_mesh2d = [];
id_mesh1d = [];
id_layer  = [];
centering = 0;

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
f_fprintf(0,'Make #c3d_prismmesh',1,id_mesh3d);

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
if f_istrue(centering)
    cx = mean(node(1,:));
    cy = mean(node(2,:));
    cz = mean(node(3,:));
    node(1,:) = node(1,:) - cx;
    node(2,:) = node(2,:) - cy;
    node(3,:) = node(3,:) - cz;
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
celem = mean(reshape(node(:,elem(1:6,:)),3,6,nb_elem),2);
%--------------------------------------------------------------------------
face = f_face(elem,'elem_type','prism');
nb_face = size(face,2);
cface   = zeros(3,nb_face);
id_tria = find(face(4,:) == 0);
id_quad = setdiff(1:nb_face,id_tria);
cface(:,id_tria) = mean(reshape(node(:,face(1:3,id_tria)),3,3,length(id_tria)),2);
cface(:,id_quad) = mean(reshape(node(:,face(1:4,id_quad)),3,4,length(id_quad)),2);
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
c3dobj.mesh3d.(id_mesh3d).celem = squeeze(celem);
c3dobj.mesh3d.(id_mesh3d).face = face;
c3dobj.mesh3d.(id_mesh3d).cface = squeeze(cface);
%--------------------------------------------------------------------------
c3dobj.mesh3d.(id_mesh3d).edge = f_edge(c3dobj.mesh3d.(id_mesh3d).elem, ...
                            'elem_type',c3dobj.mesh3d.(id_mesh3d).elem_type);
%--------------------------------------------------------------------------
% --- Log message
f_fprintf(0, '--- in',...
          1, toc, ...
          0, 's \n');




