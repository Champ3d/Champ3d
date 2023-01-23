function [filface,id_face] = f_filterface(face)
% F_FILTERFACE returns arrays of faces with separated face type.
%--------------------------------------------------------------------------
% FIXED INPUT
% face : nb_nodes_per_face x nb_faces
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% filface : cell array {nb_face_types} of faces with separated face type.
% id_face : cell array {nb_face_types} of original indices of faces
%--------------------------------------------------------------------------
% EXAMPLE
% filtered_face = F_FILTERFACE(face);
%   --> filtered_face{1}
%       filtered_face{2}...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
[r,c] = find(face == 0);
nbFace = size(face,2);
gr = {};
if ~isempty(r)
    ir = unique(r);
    for i = 1:length(ir)
        gr{i} = find(r == ir(i));
    end
    for i = 1:size(gr,2)
        iElem = c(gr{i});
        filface{i} = face(1:ir(i)-1,iElem);
        id_face{i} = iElem;
    end
    n = setdiff(1:size(face,2),c);
    filface{size(gr,2)+1} = face(:,n);
    id_face{size(gr,2)+1} = n;
else
    filface{1} = face;
    id_face{1} = 1:nbFace;
end
