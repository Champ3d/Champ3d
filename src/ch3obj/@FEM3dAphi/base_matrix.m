%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function base_matrix(obj)

%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Base',1,class(obj),0,'\n');
%--------------------------------------------------------------------------
obj.build;
%--------------------------------------------------------------------------
parent_mesh = obj.parent_mesh;
nb_elem = parent_mesh.nb_elem;
nb_face = parent_mesh.nb_face;
nb_edge = parent_mesh.nb_edge;
nb_node = parent_mesh.nb_node;
%--------------------------------------------------------------------------
obj.matrix.id_edge_a = 1:nb_edge;
%--------------------------------------------------------------------------
refelem = parent_mesh.refelem;
nbEd_inEl = refelem.nbEd_inEl;
nbFa_inEl = refelem.nbFa_inEl;
% ---
id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
% ---
obj.matrix.id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
obj.matrix.id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
obj.matrix.id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
%--------------------------------------------------------------------------
id_nomesh__ = {};
id_airbox__ = {};
id_mconductor__ = {};
% ---
if ~isempty(obj.airbox)
    id_airbox__ = fieldnames(obj.airbox);
end
% ---
if ~isempty(obj.nomesh)
    id_nomesh__ = fieldnames(obj.nomesh);
end
% ---
if ~isempty(obj.mconductor)
    id_mconductor__ = fieldnames(obj.mconductor);
end
%--------------------------------------------------------------------------
% --- nomesh
id_elem_nomesh = [];
id_inner_edge_nomesh = [];
id_inner_node_nomesh = [];
for iec = 1:length(id_nomesh__)
    %----------------------------------------------------------------------
    id_phydom = id_nomesh__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #nomesh',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_elem = obj.nomesh.(id_phydom).matrix.gid_elem;
    id_inner_edge = obj.nomesh.(id_phydom).matrix.gid_inner_edge;
    id_inner_node = obj.nomesh.(id_phydom).matrix.gid_inner_node;
    %----------------------------------------------------------------------
    id_elem_nomesh = [id_elem_nomesh id_elem];
    id_inner_edge_nomesh = [id_inner_edge_nomesh f_torowv(id_inner_edge)];
    id_inner_node_nomesh = [id_inner_node_nomesh f_torowv(id_inner_node)];
end
% ---
id_elem_nomesh = unique(id_elem_nomesh);
id_inner_edge_nomesh = unique(id_inner_edge_nomesh);
id_inner_node_nomesh = unique(id_inner_node_nomesh);
% ---
obj.matrix.id_elem_nomesh = id_elem_nomesh;
obj.matrix.id_inner_edge_nomesh = id_inner_edge_nomesh;
obj.matrix.id_inner_node_nomesh = id_inner_node_nomesh;
%--------------------------------------------------------------------------
% --- mconductor
id_elem_mcon = [];
for iec = 1:length(id_mconductor__)
    %----------------------------------------------------------------------
    id_phydom = id_mconductor__{iec};
    %----------------------------------------------------------------------
    id_elem_mcon = [id_elem_mcon obj.mconductor.(id_phydom).matrix.gid_elem];
    %----------------------------------------------------------------------
end
% ---
id_elem_mcon = unique(id_elem_mcon);
% ---
obj.matrix.id_elem_mcon = id_elem_mcon;
%--------------------------------------------------------------------------
% --- airbox
id_phydom = id_airbox__{1};
id_elem_airbox = unique(obj.airbox.(id_phydom).matrix.gid_elem);
id_inner_edge_airbox = unique(obj.airbox.(id_phydom).matrix.gid_inner_edge);
%---
obj.matrix.id_elem_airbox = id_elem_airbox;
obj.matrix.id_inner_edge_airbox = id_inner_edge_airbox;
%--------------------------------------------------------------------------
% --- wfwf / wfwfx
no_wfwf = 0;
if ~isfield(obj,'matrix')
    no_wfwf = 1;
elseif ~isfield(obj.matrix,'wfwf')
    no_wfwf = 1;
elseif isempty(obj.matrix.wfwf)
    no_wfwf = 1;
end
no_wfwfx = 0;
if ~isfield(obj,'matrix')
    no_wfwfx = 1;
elseif ~isfield(obj.matrix,'wfwfx')
    no_wfwfx = 1;
elseif isempty(obj.matrix.wfwfx)
    no_wfwfx = 1;
end
% ---
if no_wfwf || no_wfwfx
    % ---
    lmatrix = parent_mesh.cwfwf;
    % ---
    if no_wfwf
        % ---
        wfwf = sparse(nb_face,nb_face);
        for i = 1:nbFa_inEl
            for j = i+1 : nbFa_inEl
                wfwf = wfwf + ...
                    sparse(id_face_in_elem(i,:),id_face_in_elem(j,:),...
                           lmatrix(:,i,j),nb_face,nb_face);
            end
        end
        % ---
        wfwf = wfwf + wfwf.';
        % ---
        for i = 1:nbFa_inEl
            wfwf = wfwf + ...
                sparse(id_face_in_elem(i,:),id_face_in_elem(i,:),...
                       lmatrix(:,i,i),nb_face,nb_face);
        end
    end
    if no_wfwfx
        lmatrix([id_elem_nomesh id_elem_mcon],:,:) = 0;
        % ---
        wfwfx = sparse(nb_face,nb_face);
        for i = 1:nbFa_inEl
            for j = i+1 : nbFa_inEl
                wfwfx = wfwfx + ...
                    sparse(id_face_in_elem(i,:),id_face_in_elem(j,:),...
                           lmatrix(:,i,j),nb_face,nb_face);
            end
        end
        % ---
        wfwfx = wfwfx + wfwfx.';
        % ---
        for i = 1:nbFa_inEl
            wfwfx = wfwfx + ...
                sparse(id_face_in_elem(i,:),id_face_in_elem(i,:),...
                       lmatrix(:,i,i),nb_face,nb_face);
        end
    end
end
% ---
obj.matrix.wfwf  = wfwf;  clear wfwf
obj.matrix.wfwfx = wfwfx; clear wfwfx
%--------------------------------------------------------------------------
% --- wewe / wewex
no_wewe = 0;
if ~isfield(obj,'matrix')
    no_wewe = 1;
elseif ~isfield(obj.matrix,'wewe')
    no_wewe = 1;
elseif isempty(obj.matrix.wewe)
    no_wewe = 1;
end
no_wewex = 0;
if ~isfield(obj,'matrix')
    no_wewex = 1;
elseif ~isfield(obj.matrix,'wewex')
    no_wewex = 1;
elseif isempty(obj.matrix.wewex)
    no_wewex = 1;
end
% ---
if no_wewe || no_wewex
    % ---
    lmatrix = parent_mesh.cwewe;
    % ---
    if no_wewe
        % ---
        wewe = sparse(nb_edge,nb_edge);
        for i = 1:nbEd_inEl
            for j = i+1:nbEd_inEl
                wewe = wewe + ...
                    sparse(id_edge_in_elem(i,:),id_edge_in_elem(j,:),...
                           lmatrix(:,i,j),nb_edge,nb_edge);
            end
        end
        % ---
        wewe = wewe + wewe.';
        % ---
        for i = 1:nbEd_inEl
            wewe = wewe + ...
                sparse(id_edge_in_elem(i,:),id_edge_in_elem(i,:),...
                       lmatrix(:,i,i),nb_edge,nb_edge);
        end
    end
    if no_wewex
        lmatrix(id_elem_nomesh,:,:) = 0;
        % ---
        wewex = sparse(nb_edge,nb_edge);
        for i = 1:nbEd_inEl
            for j = 1:nbEd_inEl
                wewex = wewex + ...
                    sparse(id_edge_in_elem(i,:),id_edge_in_elem(j,:),...
                           lmatrix(:,i,j),nb_edge,nb_edge);
            end
        end
        % ---
        wewex = wewex + wewex.';
        % ---
        for i = 1:nbEd_inEl
            wewex = wewex + ...
                sparse(id_edge_in_elem(i,:),id_edge_in_elem(i,:),...
                       lmatrix(:,i,i),nb_edge,nb_edge);
        end
    end
end
% ---
obj.matrix.wewe  = wewe;  clear wewe
obj.matrix.wewex = wewex; clear wewex
%--------------------------------------------------------------------------
% --- wewf / wewfx
no_wewf = 0;
if ~isfield(obj,'matrix')
    no_wewf = 1;
elseif ~isfield(obj.matrix,'wewf')
    no_wewf = 1;
elseif isempty(obj.matrix.wewf)
    no_wewf = 1;
end
no_wewfx = 0;
if ~isfield(obj,'matrix')
    no_wewfx = 1;
elseif ~isfield(obj.matrix,'wewfx')
    no_wewfx = 1;
elseif isempty(obj.matrix.wewfx)
    no_wewfx = 1;
end
% ---
if no_wewf || no_wewfx
    % ---
    lmatrix = parent_mesh.cwewf;
    % ---
    if no_wewf
        % ---
        wewf = sparse(nb_edge,nb_face);
        for i = 1:nbEd_inEl
            for j = 1:nbFa_inEl
                wewf = wewf + ...
                    sparse(id_edge_in_elem(i,:),id_face_in_elem(j,:),...
                           lmatrix(:,i,j),nb_edge,nb_face);
            end
        end
    end
    if no_wewfx
        lmatrix(id_elem_nomesh,:,:) = 0;
        % ---
        wewfx = sparse(nb_edge,nb_face);
        for i = 1:nbEd_inEl
            for j = 1:nbFa_inEl
                wewfx = wewfx + ...
                    sparse(id_edge_in_elem(i,:),id_face_in_elem(j,:),...
                           lmatrix(:,i,j),nb_edge,nb_face);
            end
        end
    end
end
% ---
obj.matrix.wewf  = wewf;  clear wewf
obj.matrix.wewfx = wewfx; clear wewfx
%--------------------------------------------------------------------------
end