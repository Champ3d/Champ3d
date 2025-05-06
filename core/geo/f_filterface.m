function [filface,id_face,elem_type] = f_filterface(face)
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

%--------------------------------------------------------------------------
% !!! Only work with mixed faces of 2 types with 0 last
% 
[r,c] = find(face == 0);
nbFace = size(face,2);
gr = {}; % groupe of /strange/ faces
if ~isempty(r)
    ir = unique(r);
    for i = 1:length(ir)
        gr{i} = find(r == ir(i));
    end
    nb_gr = size(gr,2);
    for i = 1:nb_gr
        iElem = c(gr{i}); % c is index of face
        filface{i} = face(1:ir(i)-1,iElem); % work only with 0 last
        id_face{i} = iElem;
        elem_type{i} = 'tri';
    end
    % /normal/ faces
    n = setdiff(1:nbFace,c);
    filface{nb_gr+1} = face(:,n);
    id_face{nb_gr+1} = n;
    elem_type{nb_gr+1} = 'quad';
else
    filface{1} = face;
    id_face{1} = 1:nbFace;
    nbNo_inFa  = size(face,1);
    if nbNo_inFa == 3
        elem_type{1} = 'tri';
    elseif nbNo_inFa == 4
        elem_type{1} = 'quad';
    end
end
