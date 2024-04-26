function [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = f_faceinelem(elem,node,face_list,varargin)
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
arglist = {'elem_type','flat_node'};

% --- default input value
elem_type = [];
flat_node = [];

% --- default ouput value
id_face_in_elem   = [];

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(f_strcmpi(arglist,varargin{2*i-1}))
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
refelem = f_refelem(elem_type);
nbNo_inEl = refelem.nbNo_inEl;
nbNo_inFa = refelem.nbNo_inFa;
nbFa_inEl = refelem.nbFa_inEl;
FaNo_inEl = refelem.FaNo_inEl;
siFa_inEl = refelem.siFa_inEl;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
[dim,nb_node] = size(node);
%--------------------------------------------------------------------------
if isempty(flat_node)
    if dim < 3
        node = [node; zeros(1,nb_node)];
        dim  = 3;
    end
end
%--------------------------------------------------------------------------
maxnbNo_inFa = max(nbNo_inFa);
f = zeros(nbFa_inEl,maxnbNo_inFa,nb_elem);
%---
celem = mean(reshape(node(:,elem(1:nbNo_inEl,:)),dim,nbNo_inEl,nb_elem),2);
celem = squeeze(celem);
sign_face_in_elem = zeros(nbFa_inEl,nb_elem);
ori_face_in_elem  = zeros(nbFa_inEl,nb_elem);
%----------------------------------------------------------------------
for i = 1:nbFa_inEl
    ft = elem(FaNo_inEl(i,1:nbNo_inFa(i)),:);
    % ---
    [ft, si_ori] = f_sortori(ft);
    ft = [ft; zeros(maxnbNo_inFa-nbNo_inFa(i),nb_elem)];
    f(i,:,:) = ft;
    % ---
    cface = mean(reshape(node(:,ft(1:nbNo_inFa(i),:)),dim,nbNo_inFa(i),[]),2);
    cface = squeeze(cface);
    % ---
    if any(f_strcmpi(elem_type,{'tri','quad','triangle'}))
        nvec = cross(cface-celem,f_chavec(node,ft,'defined_on','edge'));
        sign_face_in_elem(i,:) = sign(nvec(3,:));
    else
        sign_face_in_elem(i,:) = ...
            sign(dot(cface-celem,f_chavec(node,ft,'defined_on','face')));
    end
    % ---
    ori_face_in_elem(i,:) = si_ori;
end
%--------------------------------------------------------------------------
if ~isempty(face_list)
    id_face_in_elem = f_findvecnd(f,face_list,'position',2);
end
%--------------------------------------------------------------------------
end