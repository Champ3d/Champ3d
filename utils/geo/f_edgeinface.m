function [id_edge_in_face, ori_edge_in_face, sign_edge_in_face] = f_edgeinface(face,edge_list,varargin)
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

% --- valid argument list (to be updated each time modifying function)
arglist = {''};

% --- default input value

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
maxnbNo_inFa = size(face,1);
%--------------------------------------------------------------------------
if maxnbNo_inFa < 3
    id_edge_in_face   = 0;
    ori_edge_in_face  = 0;
    sign_edge_in_face = 0;
    return
end
%--------------------------------------------------------------------------
nb_face = size(face,2);
%--------------------------------------------------------------------------
itria = [];
iquad = [];
if maxnbNo_inFa == 3
    itria = 1:nb_face;
    iquad = [];
    maxnbEd_inFa = 3;
elseif maxnbNo_inFa == 4
    itria = find(face(4,:) == 0);
    iquad = setdiff(1:nb_face,itria);
    maxnbEd_inFa = 4;
end
%--------------------------------------------------------------------------
id_edge_in_face   = zeros(maxnbEd_inFa,nb_face);
ori_edge_in_face  = zeros(maxnbEd_inFa,nb_face);
sign_edge_in_face = zeros(maxnbEd_inFa,nb_face);
%--------------------------------------------------------------------------
if ~isempty(itria)
    face_ = face(1:3,itria);
    [id_ed, ori_edge, sign_edge] = ...
        f_edgeinelem(face_,edge_list,'defined_on','face');
    id_edge_in_face(1:3,itria) = id_ed;
    ori_edge_in_face(1:3,itria) = ori_edge;
    sign_edge_in_face(1:3,itria) = sign_edge;
end
%--------------------------------------------------------------------------
if ~isempty(iquad)
    face_ = face(1:4,iquad);
    [id_ed, ori_edge, sign_edge] = ...
        f_edgeinelem(face_,edge_list,'defined_on','face');
    id_edge_in_face(1:4,iquad) = id_ed;
    ori_edge_in_face(1:4,iquad) = ori_edge;
    sign_edge_in_face(1:4,iquad) = sign_edge;
end
%--------------------------------------------------------------------------