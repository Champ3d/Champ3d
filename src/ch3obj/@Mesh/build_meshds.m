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
         'ori_edge_in_face','sign_edge_in_face'})} = 'all'
end
%--------------------------------------------------------------------------
if obj.build_meshds_done
    return
end
%--------------------------------------------------------------------------
tic
f_fprintf(0,'Make #meshds \n');
fprintf('   ');
% ---
get = args.get;
% ---
node = obj.node;
elem = obj.elem;
elem_type = obj.elem_type;
nb_elem = size(elem,2);
refelem = obj.refelem;
nbNo_inEl = refelem.nbNo_inEl;
nbFa_inEl = refelem.nbFa_inEl;
nbEd_inFa = refelem.nbEd_inFa;
nbNo_inEd = refelem.nbNo_inEd;
siNo_inEd = refelem.siNo_inEd;
nbEd_inEl = refelem.nbEd_inEl;
%--------------------------------------------------------------------------
%----- barrycenter
all_get = {'all','celem'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.celem)
        dim = size(node,1);
        obj.celem = mean(reshape(node(:,elem(1:nbNo_inEl,:)),dim,nbNo_inEl,nb_elem),2);
        obj.celem = squeeze(obj.celem);
    end
end
%--------------------------------------------------------------------------
%----- edges
all_get = {'all','edge','id_edge_in_elem'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.edge)
        obj.edge = f_edge(elem,'elem_type',elem_type);
    end
    if isempty(obj.meshds.id_edge_in_elem)
        [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = ...
            f_edgeinelem(elem,obj.edge,'elem_type',elem_type);
        % ---
        obj.meshds.id_edge_in_elem   = id_edge_in_elem;
        obj.meshds.ori_edge_in_elem  = ori_edge_in_elem;
        obj.meshds.sign_edge_in_elem = sign_edge_in_elem;
    end
end
% ---
all_get = {'all','cedge'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.edge)
        obj.edge = f_edge(elem,'elem_type',elem_type);
    end
    if isempty(obj.cedge)
        edge_ = obj.edge;
        nb_edge_ = size(edge_,2);
        dim = size(node,1);
        obj.cedge = mean(reshape(node(:,edge_(1:nbNo_inEd,:)),dim,nbNo_inEd,nb_edge_),2);
        obj.cedge = squeeze(obj.cedge);
    end
end
%--------------------------------------------------------------------------
%----- faces
all_get = {'all','face','sign_face_in_elem'};
if any(f_strcmpi(get,all_get))
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
end
% ---
all_get = {'all','cface'};
if any(f_strcmpi(get,all_get))
    if isempty(obj.face)
        obj.face = f_face(elem,'elem_type',elem_type);
    end
    if isempty(obj.cface)
        dim = size(node,1);
        [filface,id_face_] = f_filterface(obj.face);
        obj.cface = zeros(dim,size(obj.face,2));
        for i = 1:length(filface)
            face_ = filface{i};
            nb_face_ = size(face_,2);
            nbNo_inFa = size(face_,1);
            obj.cface(:,id_face_{i}) = squeeze(mean(reshape(node(:,face_(1:nbNo_inFa,:)),dim,nbNo_inFa,nb_face_),2));
        end
    end
end
%--------------------------------------------------------------------------
%----- edge/face
all_get = {'all','id_edge_in_face','edge_in_face'};
if any(f_strcmpi(get,all_get))
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
end
%--------------------------------------------------------------------------
all_get = {'all'};
if any(f_strcmpi(get,all_get))
    obj.build_meshds_done = 1;
end
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');
end