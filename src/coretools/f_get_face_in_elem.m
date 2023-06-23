function [face_in_elem, sign_face_in_elem, ori_face_in_elem] = f_get_face_in_elem(mesh3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type'};

% --- default input value
elem_type = [];

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
    fprintf(['Build meshds for ' elem_type ' \n']);
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
if ~isfield(mesh3d,'face')
    face = f_get_face(mesh3d);
elseif isempty(mesh3d.face)
    face = f_get_face(mesh3d);
else
    face = mesh3d.face;
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbNo_inFa = con.nbNo_inFa;
nbFa_inEl = con.nbFa_inEl;
FaNo_inEl = con.FaNo_inEl;

%--------------------------------------------------------------------------
node = mesh3d.node;
elem = mesh3d.elem;
nbElem = size(elem,2);
%--------------------------------------------------------------------------
maxnbNo_inFa = max(nbNo_inFa);
f = zeros(nbFa_inEl,maxnbNo_inFa,nbElem);
sign_face_in_elem = zeros(nbFa_inEl,nbElem);
ori_face_in_elem = zeros(nbFa_inEl,nbElem);
%---
celem = mean(reshape(node(:,elem(1:nbNo_inEl,:)),3,nbNo_inEl,nbElem),2);
celem = squeeze(celem);
%--------------------------------------------------------------------------
for i = 1:nbFa_inEl
    ft = elem(FaNo_inEl(i,1:nbNo_inFa(i)),:);
    % ---
    [ft, si_ori] = f_sortori(ft);
    ft = [ft; zeros(maxnbNo_inFa-nbNo_inFa(i),nbElem)];
    f(i,:,:) = ft;
    % ---
    cface = mean(reshape(node(1:3,ft(1:nbNo_inFa(i),:)),3,nbNo_inFa(i),[]),2);
    cface = squeeze(cface);
    % ---
    sign_face_in_elem(i,:) = sign(dot(cface-celem,f_chavec(node,ft,'face')));
    ori_face_in_elem(i,:) = si_ori;
end
%--------------------------------------------------------------------------
face_in_elem = f_findvecnd(f,face,'position',2);
%--------------------------------------------------------------------------
% --- Outputs
% mesh3d.face_in_elem      = face_in_elem;
% mesh3d.sign_face_in_elem = sign_face_in_elem;
% mesh3d.ori_face_in_elem  = ori_face_in_elem;

end