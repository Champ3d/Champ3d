function c3dobj = f_add_nomesh(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_design3d','id_dom3d','id_nomesh'};

% --- default input value
id_design3d = [];
id_nomesh = [];
id_dom3d = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No nomesh to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if isempty(id_design3d)
    id_design3d = fieldnames(c3dobj.design3d);
    id_design3d = id_design3d{1};
end

if isempty(id_nomesh)
    error([mfilename ': id_nomesh must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be defined !'])
end

%--------------------------------------------------------------------------
id_mesh3d = c3dobj.design3d.(id_design3d).id_mesh3d;
nomesh    = c3dobj.geo3d.mesh3d.(id_mesh3d);
id_elem   = 
%--------------------------------------------------------------------------
bcmesh = f_make_mds(nomesh.node,...
                    nomesh.elem(:,id_elem),...
                    nomesh.elem_type);
% ---
con = f_connexion(nomesh.elem_type);
nbNo_inFa_max = max(con.nbNo_inFa);
id_face = f_findvec(bcmesh.bound(1:nbNo_inFa_max,:),...
                    nomesh.face(1:nbNo_inFa_max,:));
s_face  = f_measure(nomesh.node,nomesh.face(:,id_face),'face');
%--------------------------------------------------------------------------
nbEd_inFa_max = 0;
for i = 1:length(con.nbEd_inFa)
    nbEd_inFa_max = max([nbEd_inFa_max con.nbEd_inFa{i}]);
end
%--------------------------------------------------------------------------
id_edge = reshape(nomesh.edge_in_face(1:nbEd_inFa_max,id_face),...
                  1,nbEd_inFa_max*length(id_face));
id_edge = unique(id_edge);
id_edge(id_edge == 0) = [];
%--------------------------------------------------------------------------
id_node = reshape(nomesh.edge(1:2,id_edge),...
                  1,2*length(id_edge));
id_node = unique(id_node);
id_node(id_node == 0) = [];
%--------------------------------------------------------------------------
all_edge = nomesh.edge_in_elem(1:con.nbEd_inEl,id_elem);
id_inside_edge = setdiff(all_edge, id_edge);
id_inside_edge = unique(id_inside_edge);
id_inside_edge(id_inside_edge == 0) = [];
%--------------------------------------------------------------------------
% --- Output
c3dobj.nomesh.(id_nomesh).id_dom3d = id_dom3d;
c3dobj.nomesh.(id_nomesh).id_elem  = id_elem;
c3dobj.nomesh.(id_nomesh).id_face  = id_face;
c3dobj.nomesh.(id_nomesh).id_edge  = id_edge;
c3dobj.nomesh.(id_nomesh).id_node  = id_node;
c3dobj.nomesh.(id_nomesh).s_face   = s_face;
c3dobj.nomesh.(id_nomesh).id_inside_edge = id_inside_edge;
% --- info message
fprintf(['Add nomesh ' id_nomesh '\n']);
