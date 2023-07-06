function [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = f_faceinelem(elem,node,face_list,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','get'};

% --- default input value
elem_type = [];
get = [];

% --- default ouput value
sign_face_in_elem = [];
ori_face_in_elem  = [];

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
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbNo_inFa = con.nbNo_inFa;
nbFa_inEl = con.nbFa_inEl;
FaNo_inEl = con.FaNo_inEl;
siFa_inEl = con.siFa_inEl;
%--------------------------------------------------------------------------
nbElem = size(elem,2);
%--------------------------------------------------------------------------

if any(strcmpi(elem_type,{'tri','quad','triangle'}))
    %----------------------------------------------------------------------
    f = reshape([elem(FaNo_inEl(:,1),:); elem(FaNo_inEl(:,2),:)], ...
                 nbFa_inEl, nbNo_inFa, nbElem);
    % ---
    if any(strcmpi(get,{'topo','ori','orientation'}))
        ori_face_in_elem = squeeze(sign(diff(f, 1, 2))); % with unsorted e !
        
    end
    if any(strcmpi(get,{'topo','sign','si'}))
        sign_face_in_elem = ori_face_in_elem .* siFa_inEl.';
    end
    % ---
    f = sort(f, 2);
else
    %----------------------------------------------------------------------
    maxnbNo_inFa = max(nbNo_inFa);
    f = zeros(nbFa_inEl,maxnbNo_inFa,nbElem);
    %---
    if any(strcmpi(get,{'topo','sign','si'}))
        celem = mean(reshape(node(:,elem(1:nbNo_inEl,:)),3,nbNo_inEl,nbElem),2);
        celem = squeeze(celem);
        sign_face_in_elem = zeros(nbFa_inEl,nbElem);
    end
    if any(strcmpi(get,{'topo','ori','orientation'}))
        ori_face_in_elem = zeros(nbFa_inEl,nbElem);
    end
    %----------------------------------------------------------------------
    for i = 1:nbFa_inEl
        ft = elem(FaNo_inEl(i,1:nbNo_inFa(i)),:);
        % ---
        [ft, si_ori] = f_sortori(ft);
        ft = [ft; zeros(maxnbNo_inFa-nbNo_inFa(i),nbElem)];
        f(i,:,:) = ft;
        % ---
        if any(strcmpi(get,{'topo','sign','si'}))
            % ---
            cface = mean(reshape(node(1:3,ft(1:nbNo_inFa(i),:)),3,nbNo_inFa(i),[]),2);
            cface = squeeze(cface);
            % ---
            sign_face_in_elem(i,:) = sign(dot(cface-celem,f_chavec(node,ft,'face')));
        end
        if any(strcmpi(get,{'topo','ori','orientation'}))
            ori_face_in_elem(i,:) = si_ori;
        end
    end
end
%--------------------------------------------------------------------------
id_face_in_elem = f_findvecnd(f,face_list,'position',2);
%--------------------------------------------------------------------------
end