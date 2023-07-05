function [inter_face, lid_inter_face, info] = f_get_inter_face(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('get_inter_face');

% --- default input value
id_mesh3d = [];
of_dom3d = [];
get = []; % 'ndecomposition' = 'ndec' = 'n-decomposition'
n_direction = 'outward'; % 'outward' = 'out' = 'o', 'inward' = 'in' = 'i'
                         %  otherwise : 'automatic' = 'natural' = 'auto'
n_component = []; % 1, 2 or 3
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end
%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    error([mfilename ': no mesh3d found !']);
else
    mesh3d = c3dobj.mesh3d.(id_mesh3d);
end
%--------------------------------------------------------------------------
of_dom3d = f_to_dcellargin(of_dom3d,'forced','on');
domlist  = '';
for j = 1:length(of_dom3d{1})
    domlist = [domlist '#' of_dom3d{1}{j} ' '];
end
%--------------------------------------------------------------------------
bound_face = {};
lid_bound_face = {};
for i = 1:length(of_dom3d)
    bound_face{i} = [];
    lid_bound_face{i} = [];
    for j = 1:length(of_dom3d{i})
        [bf, lid_bf] = ...
            f_get_bound_face(c3dobj,'id_mesh3d',id_mesh3d,'of_dom3d',of_dom3d{i}{j},...
              'get',get,'n_direction',n_direction,'n_component',n_component);
        bound_face{i} = [bound_face{i} bf];
        if i == 1
            lid_bound_face{i} = [lid_bound_face{i} lid_bf];
            info = ['inter_face with ' n_direction '-normal to ' domlist];
        end
    end
end
%--------------------------------------------------------------------------
[inter_face,lid_inter_face] = f_intersectvec(bound_face{1},bound_face{2});
%lid_inter_face = f_findvecnd(inter_face,bface{1});
%[lid_inter_face,id_bfof1] = intersect(id_bface{1},id_bface{2});

%--------------------------------------------------------------------------
% --- bound with n-decomposition
if any(strcmpi(get,{'nd','ndec','ndecomposition','n-decomposition'}))
    bf = inter_face;
    id_bf = lid_inter_face;
    nface = f_chavec(c3dobj.mesh3d.(id_mesh3d).node,inter_face);
    if isempty(n_component)
        [~,~,inface] = f_unique(nface,'by','strict_value','get','groupsort');
        addinfo = [];
    elseif isnumeric(n_component)
        [~,inface] = f_groupsort(nface,'group_component',n_component);
        addinfo = [' by ' num2str(n_component) '-component'];
    end
    nb_gr = length(inface);
    inter_face = {};
    lid_inter_face = {};
    for i = 1:nb_gr
        inter_face{i} = bf(:,inface{i});
        lid_inter_face{i} = id_bf(inface{i});
    end
    %----------------------------------------------------------------------
    % Add information
    info = [info ' with n-decomposition' addinfo];
end
%--------------------------------------------------------------------------
% for i = 1:length(of_dom3d)
%     msh = [];
%     msh.node = mesh3d.node;
%     id3d = i;
%     if id3d > 2; id3d = 2; end
%     msh.elem = [];
%     for j = 1:length(of_dom3d{i})
%         msh.elem = [msh.elem  mesh3d.elem(:,mesh3d.dom3d.(of_dom3d{i}{j}).id_elem)];
%     end
%      msh = f_get_bound_face(msh,'n_direction',n_direction);
%      bface{id3d} = msh.bound_face;
%      id_bface{id3d} = msh.idl_bound_face;
% end
% lid_inter_face = f_findvecnd(bface{2},bface{1});
% [lid_inter_face,id_bfof1] = intersect(id_bface{1},id_bface{2});
% inter_face = bface{1}(:,id_bfof1);




