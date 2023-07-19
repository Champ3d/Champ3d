function mesh3d = f_meshds3d(mesh3d,varargin)
% F_MESHDS3D
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
get = '_all'; % 'cnode' = 'center', 'edge', 'face', 'bound', 'interface'

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
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
    error([mfilename ': #elem_type must be given !']);
end
%--------------------------------------------------------------------------
if ~isfield(mesh3d,'elem_type')
    mesh3d.elem_type = elem_type;
end
%--------------------------------------------------------------------------

tic
fprintf('Making meshds3d');


%--------------------------------------------------------------------------
%----- barrycenter
if any(strcmpi(get,{'_all', 'cnode','center'}))
    con = f_connexion(elem_type);
    nbNo_inEl = con.nbNo_inEl;
    mesh3d.celem = squeeze(mean(reshape(mesh3d.node(:,mesh3d.elem(1:nbNo_inEl,:)),3,nbNo_inEl,size(mesh3d.elem,2)),2));
end

%----- edges
if any(strcmpi(get,{'_all', 'edge'}))
    mesh3d = f_get_edge(mesh3d,'elem_type',mesh3d.elem_type);
end

%----- faces
if any(strcmpi(get,{'_all', 'face'}))
    mesh3d = f_get_face(mesh3d,'elem_type',mesh3d.elem_type);
end

%----- D
if any(strcmpi(get,{'_all', 'D', 'Div'}))
    % ---
    if ~all(isfield(mesh3d,{'face'}))
        mesh3d = f_get_face(mesh3d,'elem_type',mesh3d.elem_type);
    end
    % ---
    if ~all(isfield(mesh3d,{'face_in_elem','sign_face_in_elem'}))
        mesh3d = f_get_face_in_elem(mesh3d,'elem_type',mesh3d.elem_type);
    end
    % ---
    face_in_elem = mesh3d.face_in_elem;
    sign_face_in_elem = mesh3d.sign_face_in_elem;
    nbElem = size(mesh3d.elem, 2);
    nbFace = size(mesh3d.face, 2);
    con = f_connexion(elem_type);
    nbFa_inEl = con.nbFa_inEl;
    % ---
    mesh3d.D = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        mesh3d.D = mesh3d.D + sparse(1:nbElem,face_in_elem(i,:),sign_face_in_elem(i,:),nbElem,nbFace);
    end
end

%----- R
if any(strcmpi(get,{'_all', 'R', 'Rot', 'Curl'}))
    % ---
    if ~all(isfield(mesh3d,{'edge'}))
        mesh3d = f_get_edge(mesh3d,'elem_type',mesh3d.elem_type);
    end
    % ---
    if ~all(isfield(mesh3d,{'face'}))
        mesh3d = f_get_face(mesh3d,'elem_type',mesh3d.elem_type);
    end
    % ---
    if ~all(isfield(mesh3d,{'edge_in_face','sign_edge_in_face'}))
        mesh3d = f_get_edge_in_face(mesh3d,'elem_type',mesh3d.elem_type);
    end
    % ---
    edge_in_face = mesh3d.edge_in_face;
    sign_edge_in_face = mesh3d.sign_edge_in_face;
    nbEdge = size(mesh3d.edge, 2);
    nbFace = size(mesh3d.face, 2);
    con = f_connexion(elem_type);
    nbEd_inFa = con.nbEd_inFa;
    % ---
    itria = find(mesh3d.face(4,:) == 0);
    iquad = setdiff(1:nbFace,itria);
    mesh3d.R = sparse(nbFace,nbEdge);
    for k = 1:2 %---- 2 faceType
        switch k
            case 1
                iface = itria;
            case 2
                iface = iquad;
        end
        for i = 1:nbEd_inFa{k}
            mesh3d.R = mesh3d.R + sparse(iface,edge_in_face(i,iface),sign_edge_in_face(i,iface),nbFace,nbEdge);
        end
    end
end

%----- G
if any(strcmpi(get,{'_all', 'G', 'Grad', 'Gradient'}))
    if ~all(isfield(mesh3d,{'node','edge','edge_in_face','sign_edge_in_face'}))
        mesh3d = f_get_edge(mesh3d,'elem_type',mesh3d.elem_type);
        mesh3d = f_get_face(mesh3d,'elem_type',mesh3d.elem_type);
    end
    edge = mesh3d.edge;
    nbNode = size(mesh3d.node, 2);
    nbEdge = size(mesh3d.edge, 2);
    con = f_connexion(elem_type);
    nbNo_inEd = con.nbNo_inEd;
    siNo_inEd = con.siNo_inEd;
    % ---
    mesh3d.G = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        mesh3d.G = mesh3d.G + sparse(1:nbEdge,edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
end

%----- check
if isfield(mesh3d,'D') && isfield(mesh3d,'R') 
    if any(mesh3d.D * mesh3d.R)
        error([mfilename ': error on mesh entry, DivRot is not null !']);
    end
end

if isfield(mesh3d,'R') && isfield(mesh3d,'G') 
    if any(mesh3d.R * mesh3d.G)
        error([mfilename ': error on mesh entry, RotGrad is not null !']);
    end
end


%--------------------------------------------------------------------------
fprintf(' --- in %.2f s \n',toc);



end