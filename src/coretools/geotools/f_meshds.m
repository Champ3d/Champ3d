function mesh = f_meshds(mesh,varargin)
% F_MESHD
% --------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
% --------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
% --------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','get','defined_on','flat_node'};

% --- default input value
elem_type = [];
get = '_all'; % 'cnode' = 'center', 'edge', 'face', 'bound', 'interface'
defined_on = [];
flat_node = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~isfield(mesh,'node') || ~isfield(mesh,'elem')
    error([mfilename ': #mesh struct must contain at least .node and .elem !' ]);
end
%--------------------------------------------------------------------------
if isempty(elem_type) && isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    if ~isempty(defined_on)
        elem_type = f_elemtype(mesh.elem,'defined_on','elem');
    else
        error([mfilename ': #elem_type or #defined_on must be given !' ]);
    end
end
%--------------------------------------------------------------------------
if ~isfield(mesh,'elem_type')
    mesh.elem_type = elem_type;
end
%--------------------------------------------------------------------------

tic
f_fprintf(0,'Make #meshds');

%--------------------------------------------------------------------------
% if isempty(flat_node)
%     
% else
% 
% end
% ---
node = mesh.node;
elem = mesh.elem;
nb_elem = size(elem,2);
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbFa_inEl = con.nbFa_inEl;
nbEd_inFa = con.nbEd_inFa;
nbNo_inEd = con.nbNo_inEd;
siNo_inEd = con.siNo_inEd;
nbEd_inEl = con.nbEd_inEl;
%--------------------------------------------------------------------------
%----- barrycenter
if any(f_strcmpi(get,{'_all', 'celem','center'}))
    if ~isfield(mesh,'celem')
        dim = size(node,1);
        mesh.celem = mean(reshape(node(:,elem(1:nbNo_inEl,:)),dim,nbNo_inEl,nb_elem),2);
        mesh.celem = squeeze(mesh.celem);
    end
end
%--------------------------------------------------------------------------
%----- edges
if any(f_strcmpi(get,{'_all','edge','id_edge_in_elem'}))
    if ~isfield(mesh,'edge')
        mesh.edge = f_edge(elem,'elem_type',elem_type);
    end
    if ~isfield(mesh,'id_edge_in_elem')
        [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
            f_edgeinelem(elem,mesh.edge,'elem_type',elem_type);
        % ---
        mesh.id_edge_in_elem   = id_edge_in_elem;
        mesh.ori_edge_in_elem  = ori_edge_in_elem;
        mesh.sign_edge_in_elem = sign_edge_in_elem;
    end
end
%--------------------------------------------------------------------------
%----- faces
if any(f_strcmpi(get,{'_all','face','id_face_in_elem','sign_face_in_elem'}))
    if ~isfield(mesh,'face')
        mesh.face = f_face(elem,'elem_type',elem_type);
    end
    % ---
    if ~all(isfield(mesh,{'id_face_in_elem','sign_face_in_elem'}))
        [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
            f_faceinelem(elem,node,mesh.face,'elem_type',elem_type);
        % ---
        mesh.id_face_in_elem   = id_face_in_elem;
        mesh.ori_face_in_elem  = ori_face_in_elem;
        mesh.sign_face_in_elem = sign_face_in_elem;
    end
end
%--------------------------------------------------------------------------
%----- Discrete Div
if any(f_strcmpi(get,{'_all','D', 'Div'}))
    % ---
    if ~all(isfield(mesh,{'face'}))
        mesh.face = f_face(elem,'elem_type',elem_type);
    end
    % ---
    if ~all(isfield(mesh,{'id_face_in_elem','sign_face_in_elem'}))
        [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
            f_faceinelem(elem,node,mesh.face,'elem_type',elem_type);
        % ---
        mesh.id_face_in_elem   = id_face_in_elem;
        mesh.ori_face_in_elem  = ori_face_in_elem;
        mesh.sign_face_in_elem = sign_face_in_elem;
    end
    % ---
    nbElem = size(mesh.elem, 2);
    nbFace = size(mesh.face, 2);
    % ---
    mesh.div = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        mesh.div = mesh.div + ...
            sparse(1:nbElem,mesh.id_face_in_elem(i,:),mesh.sign_face_in_elem(i,:),nbElem,nbFace);
    end
    % ---
    clear id_face_in_elem ori_face_in_elem sign_face_in_elem
end
%--------------------------------------------------------------------------
%----- Discrete Rot
if any(f_strcmpi(get,{'_all', 'R', 'Rot', 'Curl'}))
    if any(f_strcmpi(elem_type,{'tri', 'triangle', 'quad'}))
        % ---
        if ~all(isfield(mesh,{'edge'}))
            mesh.edge = f_edge(elem,'elem_type',elem_type);
        end
        % ---
        if ~all(isfield(mesh,{'id_face_in_elem','sign_face_in_elem'}))
            [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
                f_edgeinelem(elem,node,mesh.edge,'elem_type',elem_type);
            % ---
            mesh.id_edge_in_elem   = id_edge_in_elem;
            mesh.ori_edge_in_elem  = ori_edge_in_elem;
            mesh.sign_edge_in_elem = sign_edge_in_elem;
        end
        % ---
        nbElem = size(mesh.elem, 2);
        nbEdge = size(mesh.edge, 2);
        % ---
        mesh.rot = sparse(nbElem,nbEdge);
        for i = 1:nbEd_inEl
            mesh.rot = mesh.rot + ...
                sparse(1:nbElem,mesh.id_edge_in_elem(i,:),mesh.sign_edge_in_elem(i,:),nbElem,nbEdge);
        end
        % ---
        clear id_edge_in_elem ori_edge_in_elem sign_edge_in_elem
    else
        % ---
        if ~all(isfield(mesh,{'edge'}))
            mesh.edge = f_edge(elem,'elem_type',elem_type);
        end
        % ---
        if ~all(isfield(mesh,{'face'}))
            mesh.face = f_face(elem,'elem_type',elem_type);
        end
        % ---
        if ~all(isfield(mesh,{'id_edge_in_face','sign_edge_in_face'}))
            [id_edge_in_face, ori_edge_in_face, sign_edge_in_face] = ...
                f_edgeinface(mesh.face,mesh.edge);
            % ---
            mesh.id_edge_in_face   = id_edge_in_face;
            mesh.ori_edge_in_face  = ori_edge_in_face;
            mesh.sign_edge_in_face = sign_edge_in_face;
        end
        % ---
        nbEdge = size(mesh.edge, 2);
        nbFace = size(mesh.face, 2);
        % ---
        itria = find(mesh.face(4,:) == 0);
        iquad = setdiff(1:nbFace,itria);
        % ---
        mesh.rot = sparse(nbFace,nbEdge);
        for k = 1:2 %---- 2 faceType
            switch k
                case 1
                    iface = itria;
                case 2
                    iface = iquad;
            end
            for i = 1:nbEd_inFa{k}
                mesh.rot = mesh.rot + ...
                    sparse(iface,mesh.id_edge_in_face(i,iface),mesh.sign_edge_in_face(i,iface),nbFace,nbEdge);
            end
        end
        clear id_edge_in_face sign_edge_in_face
    end
end
%--------------------------------------------------------------------------
%----- Discrete Grad
if any(f_strcmpi(get,{'_all', 'G', 'Grad', 'Gradient'}))
    if ~all(isfield(mesh,{'edge'}))
        mesh.edge = f_edge(elem,'elem_type',elem_type);
    end
    nbNode = size(mesh.node, 2);
    nbEdge = size(mesh.edge, 2);
    % ---
    mesh.grad = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        mesh.grad = mesh.grad + ...
            sparse(1:nbEdge,mesh.edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
end
%--------------------------------------------------------------------------
%----- check
if any(f_strcmpi(elem_type,{'tri', 'triangle', 'quad'}))
    if isfield(mesh,'div') && isfield(mesh,'rot') 
        if any(any(mesh.div - mesh.rot))
            error([mfilename ': error on mesh entry, Div and Rot are not equal!']);
        end
    end
    % ---
    if isfield(mesh,'rot') && isfield(mesh,'grad') 
        if any(any(mesh.rot * mesh.grad))
            error([mfilename ': error on mesh entry, RotGrad is not null !']);
        end
    end
    %----------------------------------------------------------------------
    %--- Log message
    f_fprintf(0,'--- check ok');
else
    if isfield(mesh,'div') && isfield(mesh,'rot') 
        if any(any(mesh.div * mesh.rot))
            error([mfilename ': error on mesh entry, DivRot is not null !']);
        end
    end
    % ---
    if isfield(mesh,'rot') && isfield(mesh,'grad') 
        if any(any(mesh.rot * mesh.grad))
            error([mfilename ': error on mesh entry, RotGrad is not null !']);
        end
    end
    %--------------------------------------------------------------------------
    %--- Log message
    f_fprintf(0,'--- check ok');
end

%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');

