function [bound_face, lid_bound_face, info] = f_boundface(elem,node,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','get','n_direction','n_component'};

% --- default input value
elem_type = [];
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
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%------------------------------------------------------------------------
face = f_face(elem,'elem_type',elem_type);
[face_in_elem, sign_face_in_elem] = ...
    f_faceinelem(elem,node,face,'elem_type',elem_type,'get','sign');
%--------------------------------------------------------------------------
nb_face = size(face,2);
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbFa_inEl = con.nbFa_inEl;
%-----
elem_left_of_face = zeros(1,nb_face); % !!! convention
for i = 1:nbFa_inEl
    elem_left_of_face(face_in_elem(i,sign_face_in_elem(i,:) > 0)) = find(sign_face_in_elem(i,:) > 0);
end
%-----
dom_left_of_face = zeros(1,nb_face);
dom_left_of_face(elem_left_of_face > 0) = 1 ;%elem_code(elem_left_of_face(elem_left_of_face > 0));
%-----
elem_right_of_face = zeros(1,nb_face);
for i = 1:nbFa_inEl
    elem_right_of_face(face_in_elem(i,sign_face_in_elem(i,:) < 0)) = find(sign_face_in_elem(i,:) < 0);
end
%-----
dom_right_of_face = zeros(1,nb_face);
dom_right_of_face(elem_right_of_face > 0) = 1 ;%elem_code(elem_right_of_face(elem_right_of_face > 0));
%--------------------------------------------------------------------------
% --- bound with outward normal
ibO = find(dom_left_of_face  == 1 & dom_right_of_face == 0);
ibI = find(dom_right_of_face == 1 & dom_left_of_face  == 0);
%--------------------------------------------------------------------------
switch n_direction
    case {'o','out','outward'}
        bound_face = [face(:,ibO) f_invori(face(:,ibI))];
    case {'i','in','inward'}
        bound_face = [f_invori(face(:,ibO)) face(:,ibI)];
    otherwise
        bound_face = [face(:,ibO) face(:,ibI)];
end
%--------------------------------------------------------------------------
% id_bound_face is local to mesh3d
lid_bound_face = [];
id_bf = [];
if any(strcmpi(get,{'local_id'}))
    lid_bound_face = [ibO ibI];
    id_bf = lid_bound_face;
end
%--------------------------------------------------------------------------
% Add information
info = [];
if any(strcmpi(get,{'info'}))
    info = ['bound_face with ' n_direction '-normal'];
end
%--------------------------------------------------------------------------
% --- bound with n-decomposition
if any(strcmpi(get,{'ndec','ndecomposition','n-decomposition'}))
    bf = bound_face;
    nface = f_chavec(node,bound_face);
    if isempty(n_component)
        [~,~,inface] = f_unique(nface,'by','strict_value','get','groupsort');
        addinfo = [];
    elseif isnumeric(n_component)
        [~,inface] = f_groupsort(nface,'group_component',n_component);
        addinfo = [' by ' n_component '-component'];
    end
    nb_gr = length(inface);
    bound_face = {};
    lid_bound_face = {};
    for i = 1:nb_gr
        bound_face{i} = bf(:,inface{i});
        if any(strcmpi(get,{'local_id'}))
            lid_bound_face{i} = id_bf(inface{i});
        end
    end
    %----------------------------------------------------------------------
    % Add information
    if any(strcmpi(get,{'info'}))
        info = [info ' with n-decomposition' addinfo];
    end
end
