%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = build_discrete(obj,args)
arguments
    obj
    % ---
    args.get {mustBeMember(args.get,...
        {'all','div','grad','curl'})} = 'all'
end
%--------------------------------------------------------------------------
if obj.build_discrete_done
    return
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #discrete \n');
fprintf('   ');
% ---
get = args.get;
% ---
node = obj.node;
elem = obj.elem;
elem_type = obj.elem_type;
nb_elem = size(elem,2);
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
nbFa_inEl = con.nbFa_inEl;
nbEd_inFa = con.nbEd_inFa;
nbNo_inEd = con.nbNo_inEd;
siNo_inEd = con.siNo_inEd;
nbEd_inEl = con.nbEd_inEl;
%--------------------------------------------------------------------------
%----- Discrete Div
all_get = {'all','div'};
if any(f_strcmpi(get,all_get))
    % ---
    if isempty(obj.face)
        obj.face = f_face(elem,'elem_type',elem_type);
    end
    % ---
    if isempty(obj.meshds.id_face_in_elem) || isempty(obj.meshds.sign_face_in_elem)
        [id_face_in_elem, ori_face_in_elem, sign_face_in_elem] = ...
            f_faceinelem(elem,node,obj.face,'elem_type',elem_type);
        % ---
        obj.meshds.id_face_in_elem   = id_face_in_elem;
        obj.meshds.ori_face_in_elem  = ori_face_in_elem;
        obj.meshds.sign_face_in_elem = sign_face_in_elem;
    end
    % ---
    nbElem = size(obj.elem, 2);
    nbFace = size(obj.face, 2);
    % ---
    obj.discrete.div = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        obj.discrete.div = obj.discrete.div + ...
            sparse(1:nbElem,obj.meshds.id_face_in_elem(i,:),obj.meshds.sign_face_in_elem(i,:),nbElem,nbFace);
    end
    % ---
    clear id_face_in_elem ori_face_in_elem sign_face_in_elem
end
%--------------------------------------------------------------------------
%----- Discrete Rot
all_get = {'all','rot','curl'};
if any(f_strcmpi(get,all_get))
    if any(f_strcmpi(elem_type,{'tri', 'triangle', 'quad'}))
        % ---
        if isempty(obj.edge)
            obj.edge = f_edge(elem,'elem_type',elem_type);
        end
        % ---
        if isempty(obj.meshds.id_edge_in_elem) || isempty(obj.meshds.sign_edge_in_elem)
            [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
                f_edgeinelem(elem,node,obj.edge,'elem_type',elem_type);
            % ---
            obj.meshds.id_edge_in_elem   = id_edge_in_elem;
            obj.meshds.ori_edge_in_elem  = ori_edge_in_elem;
            obj.meshds.sign_edge_in_elem = sign_edge_in_elem;
        end
        % ---
        nbElem = size(obj.elem, 2);
        nbEdge = size(obj.edge, 2);
        % ---
        obj.discrete.rot = sparse(nbElem,nbEdge);
        for i = 1:nbEd_inEl
            obj.discrete.rot = obj.discrete.rot + ...
                sparse(1:nbElem,obj.meshds.id_edge_in_elem(i,:),obj.meshds.sign_edge_in_elem(i,:),nbElem,nbEdge);
        end
        % ---
        clear id_edge_in_elem ori_edge_in_elem sign_edge_in_elem
    else
        % ---
        if isempty(obj.edge)
            obj.edge = f_edge(elem,'elem_type',elem_type);
        end
        % ---
        if isempty(obj.face)
            obj.face = f_face(elem,'elem_type',elem_type);
        end
        % ---
        if isempty(obj.meshds.id_edge_in_face) || isempty(obj.meshds.sign_edge_in_face)
            [id_edge_in_face, ori_edge_in_face, sign_edge_in_face] = ...
                f_edgeinface(obj.face,obj.edge);
            % ---
            obj.meshds.id_edge_in_face   = id_edge_in_face;
            obj.meshds.ori_edge_in_face  = ori_edge_in_face;
            obj.meshds.sign_edge_in_face = sign_edge_in_face;
        end
        % ---
        nbEdge = size(obj.edge, 2);
        nbFace = size(obj.face, 2);
        %------------------------------------------------------------------
        maxnbNo_inFa = size(obj.face,1);
        itria = [];
        iquad = [];
        if maxnbNo_inFa == 3
            itria = 1:nbFace;
            iquad = [];
        elseif maxnbNo_inFa == 4
            itria = find(obj.face(4,:) == 0);
            iquad = setdiff(1:nbFace,itria);
        end
        % ---
        obj.discrete.rot = sparse(nbFace,nbEdge);
        for k = 1:2 %---- 2 faceType
            switch k
                case 1
                    iface = itria;
                case 2
                    iface = iquad;
            end
            for i = 1:nbEd_inFa{k}
                obj.discrete.rot = obj.discrete.rot + ...
                    sparse(iface,obj.meshds.id_edge_in_face(i,iface),obj.meshds.sign_edge_in_face(i,iface),nbFace,nbEdge);
            end
        end
        clear id_edge_in_face sign_edge_in_face
    end
end
%--------------------------------------------------------------------------
%----- Discrete Grad
all_get = {'all','grad'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.edge)
        obj.edge = f_edge(elem,'elem_type',elem_type);
    end
    nbNode = size(obj.node, 2);
    nbEdge = size(obj.edge, 2);
    % ---
    obj.discrete.grad = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        obj.discrete.grad = obj.discrete.grad + ...
            sparse(1:nbEdge,obj.edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
end
%--------------------------------------------------------------------------
all_get = {'all'};
if any(f_strcmpi(get,all_get))
    obj.build_discrete_done = 1;
end
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end