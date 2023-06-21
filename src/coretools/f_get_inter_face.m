function mesh3d = f_get_inter_face(mesh3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','of_dom3d','get','n_component','n_direction'};

% --- default input value
elem_type = [];
get = []; % 'ndecomposition' = 'ndec' = 'n-decomposition'
of_dom3d = [];
n_component = [];
n_direction = 'outward'; % 'outward' = 'out' = 'o', 'inward' = 'in' = 'i'
                         % otherwise : 'automatic' = 'natural' = 'auto'
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type) && isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
end
%--------------------------------------------------------------------------
if isempty(elem_type) && isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    nbnoinel = size(mesh3d.elem, 1);
    switch nbnoinel
        case 4
            elem_type = 'tet';
        case 6
            elem_type = 'prism';
        case 8
            elem_type = 'hex';
    end
    fprintf(['Get interface for ' elem_type ' mesh \n']);
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
of_dom3d = f_to_dcellargin(of_dom3d,'forced','on');
%--------------------------------------------------------------------------
node = mesh3d.node;
elem = {};
for i = length(of_dom3d)
    elem{i} = [];
    for j = 1:length(of_dom3d{i})
        elem{i} = [elem{i} ...
                   mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}{j}).id_elem)];
    end
end
%--------------------------------------------------------------------------
for i = 1:length(of_dom3d)
    msh = [];
    msh.node = mesh3d.node;
    id3d = i;
    if id3d > 2; id3d = 2; end
    msh.elem = [];
    for j = 1:length(of_dom3d{i})
        msh.elem = [msh.elem  mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}{j}).id_elem)];
    end
     msh = f_get_bound_face(msh,'n_direction',n_direction);
     bface{id3d} = msh.bound_face;
     id_bface{id3d} = msh.idl_bound_face;
end
id_inter_face = f_findvecnd(bface{2},bface{1});
[id_inter_face,id_bfof1] = intersect(id_bface{1},id_bface{2});
inter_face = bface{1}(:,id_bfof1);


%--------------------------------------------------------------------------
% --- bound with n-decomposition
if any(strcmpi(get,{'nd','ndec','ndecomposition','n-decomposition'}))
    bf = inter_face;
    id_bf = id_inter_face;
    nface = f_chavec(mesh3d.node,inter_face);
    if isempty(n_component)
        [~,~,inface] = f_unique(nface,'by','strict_value','get','groupsort');
    elseif isnumeric(n_component)
        [~,inface] = f_groupsort(nface,'group_component',n_component);
    end
    nb_gr = length(inface);
    inter_face = {};
    id_inter_face = {};
    for i = 1:nb_gr
        inter_face{i} = bf(:,inface{i});
        id_inter_face{i} = id_bf(inface{i});
    end
end

%--------------------------------------------------------------------------
% --- Outputs
mesh3d.inter_face = inter_face;
mesh3d.id_inter_face = id_inter_face;
