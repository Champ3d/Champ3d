function c3dobj = f_c3d_hexamesh(c3dobj,varargin)
% F_CHAMP3D_HEXA ...
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh2d','id_mesh1d','id_layer','id_mesh3d','mesher', ...
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
    id_mesh2d = fieldnames(c3dobj.mesh2d);
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
while iscell(id_mesh2d)
    id_mesh2d = id_mesh2d{1};
end
%--------------------------------------------------------------------------
if isempty(id_mesh1d)
    id_mesh1d = fieldnames(c3dobj.mesh1d);
    id_mesh1d = id_mesh1d{1};
end
if isfield(c3dobj.mesh2d.(id_mesh2d),'id_mesh1d')
    if ~isempty(id_mesh1d) && ~isempty(c3dobj.mesh2d.(id_mesh2d).id_mesh1d)
        if ~strcmpi(id_mesh1d,c3dobj.mesh2d.(id_mesh2d).id_mesh1d)
            info_message = ['Build with mesh1d #' id_mesh1d ' different from #' c3dobj.mesh2d.(id_mesh2d).id_mesh1d ' of mesh2d'];
            warning(info_message);
        end
    end
end
%--------------------------------------------------------------------------
if isempty(id_layer)
    id_layer = fieldnames(c3dobj.mesh1d.(id_mesh1d).layer);
end
%--------------------------------------------------------------------------
id_layer = f_to_scellargin(id_layer);
%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Make #c3d_hexamesh',1,id_mesh3d);
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
elem = zeros(8, nb_elem);
elem_code = zeros(1, nb_elem);

% ---
elem2d = [c3dobj.mesh2d.(id_mesh2d).elem(1,:); ...
          c3dobj.mesh2d.(id_mesh2d).elem(2,:); ...
          c3dobj.mesh2d.(id_mesh2d).elem(3,:); ...
          c3dobj.mesh2d.(id_mesh2d).elem(4,:)];
% ---
ie0 = 0;
for k = 1:nb_layer	% k : current layer
    % ---------------------------------------------------------------------
    elem(1:4,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D * (k-1);
    elem(5:8,ie0+1 : ie0+nbElem2D) = elem2d + nbNode2D *  k;
    % ---------------------------------------------------------------------
    % elem code --> encoded id (id_x, id_y, id_layer)
    elem_code(1,ie0+1 : ie0+nbElem2D)  = c3dobj.mesh2d.(id_mesh2d).elem_code * codeidl(k);
    % go to the next layer
    ie0 = ie0 + nbElem2D;
end
%--------------------------------------------------------------------------
celem = mean(reshape(node(:,elem(1:8,:)),3,8,nb_elem),2);
%--------------------------------------------------------------------------
face = f_face(elem,'elem_type','hexa');
nb_face = size(face,2);
cface = mean(reshape(node(:,face(1:4,:)),3,4,nb_face),2);
%--------------------------------------------------------------------------
edge = f_edge(elem,'elem_type','hexa');
nb_edge = size(edge,2);
cedge = mean(reshape(node(:,edge(1:2,:)),3,2,nb_edge),2);
%--------------------------------------------------------------------------
% --- Output
c3dobj.mesh3d.(id_mesh3d).mesher = 'c3d_hexamesh';
c3dobj.mesh3d.(id_mesh3d).id_mesh2d = id_mesh2d;
c3dobj.mesh3d.(id_mesh3d).id_mesh1d = id_mesh1d;
c3dobj.mesh3d.(id_mesh3d).node = node;
c3dobj.mesh3d.(id_mesh3d).nb_node = nb_node;
c3dobj.mesh3d.(id_mesh3d).elem = elem;
c3dobj.mesh3d.(id_mesh3d).nb_elem = nb_elem;
c3dobj.mesh3d.(id_mesh3d).elem_code = elem_code;
c3dobj.mesh3d.(id_mesh3d).elem_type = 'hexa';
c3dobj.mesh3d.(id_mesh3d).celem = squeeze(celem);
c3dobj.mesh3d.(id_mesh3d).face  = face;
c3dobj.mesh3d.(id_mesh3d).cface = squeeze(cface);
%--------------------------------------------------------------------------
c3dobj.mesh3d.(id_mesh3d).edge  = edge;
c3dobj.mesh3d.(id_mesh3d).cedge = squeeze(cedge);
%--------------------------------------------------------------------------
% --- Log message
f_fprintf(0,'-', ...
          1,nb_elem,...
          0,'elem',...
          0, '--- in',...
          1, toc, ...
          0, 's \n');
%--------------------------------------------------------------------------
% c3dobj.mesh3d.(id_mesh3d).cnode(1,:) = mean(reshape(node(1,elem(1:8,:)),8,nb_elem));
% c3dobj.mesh3d.(id_mesh3d).cnode(2,:) = mean(reshape(node(2,elem(1:8,:)),8,nb_elem));
% c3dobj.mesh3d.(id_mesh3d).cnode(3,:) = mean(reshape(node(3,elem(1:8,:)),8,nb_elem));


