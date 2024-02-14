%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function obj = build_meshds(obj,args)

arguments
    obj
    % ---
    args.get {mustBeMember(args.get,...
        {'all','edge','face','celem','cface','cedge','id_edge_in_elem',...
         'ori_edge_in_elem','sign_edge_in_elem','id_face_in_elem',...
         'ori_face_in_elem','sign_face_in_elem','id_edge_in_face',...
         'ori_edge_in_face','sign_edge_in_face',...
         'div','grad','curl'})} = 'all'
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #meshds');
% ---
get = args.get;
% ---
node_ = obj.node;
elem_ = obj.elem;
elem_type_ = obj.elem_type;
nb_elem_ = size(elem_,2);
con = f_connexion(elem_type_);
nbNo_inEl = con.nbNo_inEl;
nbFa_inEl = con.nbFa_inEl;
nbEd_inFa = con.nbEd_inFa;
nbNo_inEd = con.nbNo_inEd;
siNo_inEd = con.siNo_inEd;
nbEd_inEl = con.nbEd_inEl;
%--------------------------------------------------------------------------
%----- barrycenter
all_get = {'all','celem'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.celem)
        dim = size(node_,1);
        obj.celem = mean(reshape(node_(:,elem_(1:nbNo_inEl,:)),dim,nbNo_inEl,nb_elem_),2);
        obj.celem = squeeze(obj.celem);
    end
end
%--------------------------------------------------------------------------
%----- edges
all_get = {'all','edge','id_edge_in_elem'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.edge)
        obj.edge = f_edge(elem_,'elem_type',elem_type_);
    end
    if isempty(obj.id_edge_in_elem)
        [id_edge_in_elem_, ori_edge_in_elem_, sign_edge_in_elem_] = ...
            f_edgeinelem(elem_,obj.edge,'elem_type',elem_type_);
        % ---
        obj.id_edge_in_elem   = id_edge_in_elem_;
        obj.ori_edge_in_elem  = ori_edge_in_elem_;
        obj.sign_edge_in_elem = sign_edge_in_elem_;
    end
end
%--------------------------------------------------------------------------
%----- faces
all_get = {'all','face','sign_face_in_elem'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.face)
        obj.face = f_face(elem_,'elem_type',elem_type_);
    end
    % ---
    if isempty(obj.id_face_in_elem) || isempty(obj.sign_face_in_elem)
        [id_face_in_elem_, ori_face_in_elem_, sign_face_in_elem_] = ...
            f_faceinelem(elem_,node_,obj.face,'elem_type',elem_type_);
        % ---
        obj.id_face_in_elem   = id_face_in_elem_;
        obj.ori_face_in_elem  = ori_face_in_elem_;
        obj.sign_face_in_elem = sign_face_in_elem_;
    end
end
%--------------------------------------------------------------------------
%----- Discrete Div
all_get = {'all','div'};
if any(f_strcmpi(get,all_get))
    % ---
    if isempty(obj.face)
        obj.face = f_face(elem_,'elem_type',elem_type_);
    end
    % ---
    if isempty(obj.id_face_in_elem) || isempty(obj.sign_face_in_elem)
        [id_face_in_elem_, ori_face_in_elem_, sign_face_in_elem_] = ...
            f_faceinelem(elem_,node_,obj.face,'elem_type',elem_type_);
        % ---
        obj.id_face_in_elem   = id_face_in_elem_;
        obj.ori_face_in_elem  = ori_face_in_elem_;
        obj.sign_face_in_elem = sign_face_in_elem_;
    end
    % ---
    nbElem = size(obj.elem, 2);
    nbFace = size(obj.face, 2);
    % ---
    obj.div = sparse(nbElem,nbFace);
    for i = 1:nbFa_inEl
        obj.div = obj.div + ...
            sparse(1:nbElem,obj.id_face_in_elem(i,:),obj.sign_face_in_elem(i,:),nbElem,nbFace);
    end
    % ---
    clear id_face_in_elem_ ori_face_in_elem_ sign_face_in_elem_
end
%--------------------------------------------------------------------------
%----- Discrete Rot
all_get = {'all','rot','curl'};
if any(f_strcmpi(get,all_get))
    if any(f_strcmpi(elem_type_,{'tri', 'triangle', 'quad'}))
        % ---
        if isempty(obj.edge)
            obj.edge = f_edge(elem_,'elem_type',elem_type_);
        end
        % ---
        if isempty(obj.id_face_in_elem) || isempty(obj.sign_face_in_elem)
            [id_edge_in_elem_, ori_edge_in_elem_, sign_edge_in_elem_] = ...
                f_edgeinelem(elem_,node_,obj.edge,'elem_type',elem_type_);
            % ---
            obj.id_edge_in_elem   = id_edge_in_elem_;
            obj.ori_edge_in_elem  = ori_edge_in_elem_;
            obj.sign_edge_in_elem = sign_edge_in_elem_;
        end
        % ---
        nbElem = size(obj.elem, 2);
        nbEdge = size(obj.edge, 2);
        % ---
        obj.rot = sparse(nbElem,nbEdge);
        for i = 1:nbEd_inEl
            obj.rot = obj.rot + ...
                sparse(1:nbElem,obj.id_edge_in_elem(i,:),obj.sign_edge_in_elem(i,:),nbElem,nbEdge);
        end
        % ---
        clear id_edge_in_elem_ ori_edge_in_elem_ sign_edge_in_elem_
    else
        % ---
        if isempty(obj.edge)
            obj.edge = f_edge(elem_,'elem_type',elem_type_);
        end
        % ---
        if isempty(obj.face)
            obj.face = f_face(elem_,'elem_type',elem_type_);
        end
        % ---
        if isempty(obj.id_edge_in_face) || isempty(obj.sign_edge_in_face)
            [id_edge_in_face_, ori_edge_in_face_, sign_edge_in_face_] = ...
                f_edgeinface(obj.face,obj.edge);
            % ---
            obj.id_edge_in_face   = id_edge_in_face_;
            obj.ori_edge_in_face  = ori_edge_in_face_;
            obj.sign_edge_in_face = sign_edge_in_face_;
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
        obj.rot = sparse(nbFace,nbEdge);
        for k = 1:2 %---- 2 faceType
            switch k
                case 1
                    iface = itria;
                case 2
                    iface = iquad;
            end
            for i = 1:nbEd_inFa{k}
                obj.rot = obj.rot + ...
                    sparse(iface,obj.id_edge_in_face(i,iface),obj.sign_edge_in_face(i,iface),nbFace,nbEdge);
            end
        end
        clear id_edge_in_face_ sign_edge_in_face_
    end
end
%--------------------------------------------------------------------------
%----- Discrete Grad
all_get = {'all','grad'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.edge)
        obj.edge = f_edge(elem_,'elem_type',elem_type_);
    end
    nbNode = size(obj.node, 2);
    nbEdge = size(obj.edge, 2);
    % ---
    obj.grad = sparse(nbEdge,nbNode);
    for i = 1:nbNo_inEd
        obj.grad = obj.grad + ...
            sparse(1:nbEdge,obj.edge(i,:),siNo_inEd(i),nbEdge,nbNode);
    end
end
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end