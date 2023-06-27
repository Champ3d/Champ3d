function [id_edge_in_face, sign_edge_in_face] = f_edgeinface(face,edge_list,varargin)
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
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
nbFace = size(face,2);
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
if any(strcmpi(elem_type,{'quad','tri','triangle'}))
    id_edge_in_face = [];
    sign_edge_in_face = [];
    return
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
siEd_inFa = con.siEd_inFa;
EdNo_inFa = con.EdNo_inFa;
nbEd_inFa = con.nbEd_inFa;
nbNo_inEd = con.nbNo_inEd;
%--------------------------------------------------------------------------
%----- face_edge
maxnbEd_inFa = max(cell2mat(nbEd_inFa));
fe = zeros(maxnbEd_inFa,nbNo_inEd,nbFace);
itria = find(face(4,:) == 0);
iquad = setdiff(1:nbFace,itria);
%--------------------------------------------------------------------------
sign_edge_in_face = [];
if any(strcmpi(get,{'topo','ori','orientation'}))
    sign_edge_in_face = zeros(maxnbEd_inFa,nbFace);
end
%--------------------------------------------------------------------------
for k = 1:2 %---- 2 faceType
    switch k
        case 1
            iface = itria;
        case 2
            iface = iquad;
    end
    for i = 1:nbEd_inFa{k}
        fet = [];
        for j = 1:nbNo_inEd
            fet = [fet; face(EdNo_inFa{k}(i,j),iface)];
        end
        fe(i,:,iface) = fet;
        % ---
        if any(strcmpi(get,{'topo','ori','orientation'}))
            sign_edge_in_face(i,iface) = siEd_inFa{k}(i) .* sign(fet(2,:)-fet(1,:));
        end
    end
end

%--------------------------------------------------------------------------
id_edge_in_face = f_findvecnd(fe,edge_list,'position',2);
id_edge_in_face(isnan(id_edge_in_face)) = 0;
%--------------------------------------------------------------------------
end