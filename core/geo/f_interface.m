function [inter_face, lid_inter_face, info] = f_interface(elem1,elem2,node,varargin)
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
arglist = {'elem_type','of_dom3d','get','n_component','n_direction', ...
           'interface_of'};

% --- default input value
elem_type = [];
get = []; % 'ndecomposition' = 'ndec' = 'n-decomposition'
n_direction = 'outward'; % 'outward' = 'out' = 'o', 'inward' = 'in' = 'i'
                         % otherwise : 'automatic' = 'natural' = 'auto'
n_component = []; % 1, 2 or 3
interface_of = 'bound_bound'; % 'bound_bound', 'bound_face'
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
bface1 = f_boundface(elem1,node,'elem_type',elem_type,'n_direction',n_direction);
bface2 = [];
if any(strcmpi(interface_of,{'bound_bound','b_b','bb'}))
    if ~isempty(elem2)
        bface2 = f_boundface(elem2,node,'elem_type',elem_type);
    end
elseif any(strcmpi(interface_of,{'bound_face','b_f','bf'}))
    bface2 = elem2;
else
    error([mfilename ': #interface_of must be bound_bound or bound_face !']);
end
%--------------------------------------------------------------------------
if ~isempty(bface2)
    inter_face = f_intersectvec(bface1,bface2);
else
    inter_face = bface1;
end
%--------------------------------------------------------------------------
lid_inter_face = [];
id_bf = [];
if any(strcmpi(get,{'local_id'}))
    elem_type = f_elemtype(elem1,'defined_on','elem');
    face_list = f_face(elem1,'elem_type',elem_type);
    lid_inter_face = f_findvecnd(inter_face,face_list); % with face as ref
    id_bf = lid_inter_face;
end
%--------------------------------------------------------------------------
% Add information
info = [];
if any(strcmpi(get,{'info'}))
    info = ['inter_face with ' n_direction '-normal'];
end
%--------------------------------------------------------------------------
% --- bound with n-decomposition
if any(strcmpi(get,{'nd','ndec','ndecomposition','n-decomposition'}))
    bf = inter_face;
    nface = f_chavec(node,inter_face);
    if isempty(n_component)
        [~,~,inface] = f_unique(nface,'by','strict_value','get','groupsort');
        addinfo = [];
    elseif isnumeric(n_component)
        [~,inface] = f_groupsort(nface,'group_component',n_component);
        addinfo = [' by ' n_component '-component'];
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
    if any(strcmpi(get,{'info'}))
        info = [info ' with n-decomposition' addinfo];
    end
end
%--------------------------------------------------------------------------
