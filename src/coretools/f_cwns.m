function CoefWns = f_cwns(mesh,varargin)
% F_COEFWNS computes the mass matrix int_s(coef x Wn_s x ds)
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_face' : array of indices of faces in the mesh
% 'coef' : coefficient (scalar, tensor or matrix)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWns : nb_nodes_on_surface x nb_nodes_on_surface
%--------------------------------------------------------------------------
% EXAMPLE
% CoefWns = F_COEFWNS(mesh,'id_face',id_face,'coef',coef,)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'mesh','coef','id_face'};

% --- default input value
coef = 1;
id_face = [];
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------

nbFace = mesh.nbFace;
nbNode = mesh.nbNode;
if isempty(id_face)
    id_face = 1:nbFace;
end

%--------------------------------------------------------------------------

[face,id_face_out] = f_filterface(mesh.face(:,id_face));
for i = 1:length(face)
    id_face_out{i} = id_face(id_face_out{i});
    coef_face{i} = coef(id_face_out{i});
end

%--------------------------------------------------------------------------
CoefWns = sparse(nbNode,1);

for i = 1:length(face)
    idgFace = id_face_out{i};
    [flatnode,flatface] = f_flatface(mesh.node,...
                                     mesh.face(:,idgFace));
    if size(flatface,1) == 3
        mesh_out = f_mdstri(mesh.node,flatface);
    elseif size(flatface,1) == 4
        mesh_out = f_mdsquad(mesh.node,flatface);
    end
    mesh_out = f_intkit2d(mesh_out,'flatnode',flatnode);
    CoefWns = CoefWns + f_cwn(mesh_out,'coef',coef_face{i});
end

