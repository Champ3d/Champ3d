%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function assembly(obj)

% ---
parent_mesh = obj.parent_mesh;
% ---
if parent_mesh.meshds_to_be_rebuild
    parent_mesh.build_meshds;
end
% ---
if parent_mesh.intkit_to_be_rebuild
    parent_mesh.build_intkit;
end
% ---
%--------------------------------------------------------------------------
nb_elem = size(c3dobj.mesh3d.(id_mesh3d).elem,2);
nb_face = size(c3dobj.mesh3d.(id_mesh3d).face,2);
nb_edge = size(c3dobj.mesh3d.(id_mesh3d).edge,2);
nb_node = size(c3dobj.mesh3d.(id_mesh3d).node,2);
%--------------------------------------------------------------------------
% Do this first
c3dobj.emdesign.(id_emdesign).matrix.id_edge_a = 1:nb_edge;
id_edge_a = c3dobj.emdesign.(id_emdesign).matrix.id_edge_a;
%--------------------------------------------------------------------------
% Then build nomesh
c3dobj = f_build_nomesh(c3dobj,'id_emdesign',id_emdesign);
%--------------------------------------------------------------------------
% Then build airbox
c3dobj = f_build_airbox(c3dobj,'id_emdesign',id_emdesign);
%--------------------------------------------------------------------------
% Then whatever order
c3dobj = f_build_econductor(c3dobj,'id_emdesign',id_emdesign);
c3dobj = f_build_mconductor(c3dobj,'id_emdesign',id_emdesign);
c3dobj = f_build_bsfield(c3dobj,'id_emdesign',id_emdesign);
c3dobj = f_build_bc(c3dobj,'id_emdesign',id_emdesign);
c3dobj = f_build_pmagnet(c3dobj,'id_emdesign',id_emdesign);
c3dobj = f_build_coil(c3dobj,'id_emdesign',id_emdesign);

%--------------------------------------------------------------------------
id_econductor__ = {};
id_mconductor__ = {};
id_airbox__     = {};
id_bc__         = {};
id_bsfield__    = {};
id_coil__       = {};
id_nomesh__     = {};
id_pmagnet__    = {};
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'econductor')
    id_econductor__ = fieldnames(c3dobj.emdesign.(id_emdesign).econductor);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'mconductor')
    id_mconductor__ = fieldnames(c3dobj.emdesign.(id_emdesign).mconductor);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'airbox')
    id_airbox__ = fieldnames(c3dobj.emdesign.(id_emdesign).airbox);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'bc')
    id_bc__ = fieldnames(c3dobj.emdesign.(id_emdesign).bc);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'bsfield')
    id_bsfield__ = fieldnames(c3dobj.emdesign.(id_emdesign).bsfield);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'coil')
    id_coil__ = fieldnames(c3dobj.emdesign.(id_emdesign).coil);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'nomesh')
    id_nomesh__ = fieldnames(c3dobj.emdesign.(id_emdesign).nomesh);
end
% ---
if isfield(c3dobj.emdesign.(id_emdesign),'pmagnet')
    id_pmagnet__ = fieldnames(c3dobj.emdesign.(id_emdesign).pmagnet);
end
%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Assembly',1,em_model,0,'\n');
%--------------------------------------------------------------------------
con = f_connexion(c3dobj.mesh3d.(id_mesh3d).elem_type);
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
id_edge_in_elem = c3dobj.mesh3d.(id_mesh3d).id_edge_in_elem;
id_edge_in_face = c3dobj.mesh3d.(id_mesh3d).id_edge_in_face;
id_face_in_elem = c3dobj.mesh3d.(id_mesh3d).id_face_in_elem;
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
    id_elem = c3dobj.emdesign.(id_emdesign).nomesh.(id_phydom).id_elem;
    id_inner_edge = c3dobj.emdesign.(id_emdesign).nomesh.(id_phydom).id_inner_edge;
    id_inner_node = c3dobj.emdesign.(id_emdesign).nomesh.(id_phydom).id_inner_node;
    %----------------------------------------------------------------------
    id_elem_nomesh = [id_elem_nomesh id_elem];
    id_inner_edge_nomesh = [id_inner_edge_nomesh f_torowv(id_inner_edge)];
    id_inner_node_nomesh = [id_inner_node_nomesh f_torowv(id_inner_node)];
end
id_elem_nomesh = unique(id_elem_nomesh);
id_inner_edge_nomesh = unique(id_inner_edge_nomesh);
id_inner_node_nomesh = unique(id_inner_node_nomesh);
%--------------------------------------------------------------------------
% --- mconductor
nu0nurwfwf = sparse(nb_face,nb_face);
% ---
id_elem_mcon = [];
for iec = 1:length(id_mconductor__)
    %----------------------------------------------------------------------
    id_phydom = id_mconductor__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #mcon',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).mconductor.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).mconductor.(id_phydom).nu0nurwfwf;
    %----------------------------------------------------------------------
    [~,id_] = intersect(id_elem,id_elem_nomesh);
    id_elem(id_) = [];
    lmatrix(id_,:,:) = [];
    %----------------------------------------------------------------------
    for i = 1:nbFa_inEl
        for j = i+1 : nbFa_inEl
            nu0nurwfwf = nu0nurwfwf + ...
                sparse(id_face_in_elem(i,id_elem),id_face_in_elem(j,id_elem),...
                       lmatrix(:,i,j),nb_face,nb_face);
        end
    end
    %----------------------------------------------------------------------
    id_elem_mcon = [id_elem_mcon id_elem];
    %----------------------------------------------------------------------
end
% ---
nu0nurwfwf = nu0nurwfwf + nu0nurwfwf.';
% ---
for iec = 1:length(id_mconductor__)
    %----------------------------------------------------------------------
    id_phydom = id_mconductor__{iec};
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).mconductor.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).mconductor.(id_phydom).nu0nurwfwf;
    %----------------------------------------------------------------------
    [~,id_] = intersect(id_elem,id_elem_nomesh);
    id_elem(id_) = [];
    lmatrix(id_,:,:) = [];
    %----------------------------------------------------------------------
    for i = 1:nbFa_inEl
        nu0nurwfwf = nu0nurwfwf + ...
            sparse(id_face_in_elem(i,id_elem),id_face_in_elem(i,id_elem),...
                   lmatrix(:,i,i),nb_face,nb_face);
    end
end
%--------------------------------------------------------------------------
% --- wfwf / wfwfx
no_wfwf = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wfwf = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wfwf')
    no_wfwf = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wfwf)
    no_wfwf = 1;
end
no_wfwfx = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wfwfx = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wfwfx')
    no_wfwfx = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wfwfx)
    no_wfwfx = 1;
end
% ---
if no_wfwf || no_wfwfx
    phydomobj.id_dom3d = 'all_domain';
    phydomobj.id_emdesign = id_emdesign;
    lmatrix = f_cwfwf(c3dobj,'phydomobj',phydomobj,'coefficient',1);
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
c3dobj.emdesign.(id_emdesign).matrix.wfwf  = wfwf;
c3dobj.emdesign.(id_emdesign).matrix.wfwfx = wfwfx;
%--------------------------------------------------------------------------
% --- wewe / wewex
no_wewe = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wewe = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wewe')
    no_wewe = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wewe)
    no_wewe = 1;
end
no_wewex = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wewex = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wewex')
    no_wewex = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wewex)
    no_wewex = 1;
end
% ---
if no_wewe || no_wewex
    phydomobj.id_dom3d = 'all_domain';
    phydomobj.id_emdesign = id_emdesign;
    lmatrix = f_cwewe(c3dobj,'phydomobj',phydomobj,'coefficient',1);
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
c3dobj.emdesign.(id_emdesign).matrix.wewe  = wewe;
c3dobj.emdesign.(id_emdesign).matrix.wewex = wewex;
%--------------------------------------------------------------------------
% --- wewf / wewfx
no_wewf = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wewf = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wewf')
    no_wewf = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wewf)
    no_wewf = 1;
end
no_wewfx = 0;
if ~isfield(c3dobj.emdesign.(id_emdesign),'matrix')
    no_wewfx = 1;
elseif ~isfield(c3dobj.emdesign.(id_emdesign).matrix,'wewfx')
    no_wewfx = 1;
elseif isempty(c3dobj.emdesign.(id_emdesign).matrix.wewfx)
    no_wewfx = 1;
end
% ---
if no_wewf || no_wewfx
    phydomobj.id_dom3d = 'all_domain';
    phydomobj.id_emdesign = id_emdesign;
    lmatrix = f_cwewf(c3dobj,'phydomobj',phydomobj,'coefficient',1);
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
c3dobj.emdesign.(id_emdesign).matrix.wewf  = wewf;
c3dobj.emdesign.(id_emdesign).matrix.wewfx = wewfx;
%--------------------------------------------------------------------------
% --- airbox
id_phydom = id_airbox__{1};
f_fprintf(0,'--- #airbox',1,id_phydom,0,'\n');
id_elem_airbox = c3dobj.emdesign.(id_emdesign).airbox.(id_phydom).id_elem;
id_inner_edge_airbox = c3dobj.emdesign.(id_emdesign).airbox.(id_phydom).id_inner_edge;
%--------------------------------------------------------------------------
% --- econductor
sigmawewe = sparse(nb_edge,nb_edge);
id_node_phi = [];
% ---
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #econ',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigmawewe;
    %----------------------------------------------------------------------
    [~,id_] = intersect(id_elem,id_elem_nomesh);
    id_elem(id_) = [];
    lmatrix(id_,:,:) = [];
    %----------------------------------------------------------------------
    for i = 1:nbEd_inEl
        for j = i+1 : nbEd_inEl
            sigmawewe = sigmawewe + ...
                sparse(id_edge_in_elem(i,id_elem),id_edge_in_elem(j,id_elem),...
                       lmatrix(:,i,j),nb_edge,nb_edge);
        end
    end
    %----------------------------------------------------------------------
    id_node_phi = [id_node_phi ...
        c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_node_phi];
    %----------------------------------------------------------------------
end
% ---
sigmawewe = sigmawewe + sigmawewe.';
% ---
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigmawewe;
    %----------------------------------------------------------------------
    [~,id_] = intersect(id_elem,id_elem_nomesh);
    id_elem(id_) = [];
    lmatrix(id_,:,:) = [];
    %----------------------------------------------------------------------
    for i = 1:nbEd_inEl
        sigmawewe = sigmawewe + ...
            sparse(id_edge_in_elem(i,id_elem),id_edge_in_elem(i,id_elem),...
                   lmatrix(:,i,i),nb_edge,nb_edge);
    end
end

%--------------------------------------------------------------------------
% --- js-coil
t_jsfield = zeros(nb_edge,1);
id_node_netrode = [];
id_node_petrode = [];
for iec = 1:length(id_coil__)
    %----------------------------------------------------------------------
    wfjs = sparse(nb_face,1);
    %----------------------------------------------------------------------
    id_phydom = id_coil__{iec};
    coil_type = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).coil_type;
    if any(f_strcmpi(coil_type,{'close_jscoil','open_jscoil'}))
        %----------------------------------------------------------------------
        f_fprintf(0,'--- #coil/jscoil',1,id_phydom,0,'\n');
        %----------------------------------------------------------------------
        id_elem = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).id_elem;
        lmatrix = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).wfjs;
        for i = 1:nbFa_inEl
            wfjs = wfjs + ...
                   sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
        end
        %----------------------------------------------------------------------
        rotj = c3dobj.mesh3d.(id_mesh3d).rot.' * wfjs;
        rotrot = c3dobj.mesh3d.(id_mesh3d).rot.' * ...
                 c3dobj.emdesign.(id_emdesign).matrix.wfwf * ...
                 c3dobj.mesh3d.(id_mesh3d).rot;
        %----------------------------------------------------------------------
        id_edge_t_unknown = c3dobj.emdesign.(id_emdesign).matrix.id_edge_a;
        %----------------------------------------------------------------------
        rotj = rotj(id_edge_t_unknown,1);
        rotrot = rotrot(id_edge_t_unknown,id_edge_t_unknown);
        %----------------------------------------------------------------------
        int_oned_t = zeros(nb_edge,1);
        int_oned_t(id_edge_t_unknown) = f_solve_axb(rotrot,rotj);
        %----------------------------------------------------------------------
        t_jsfield = t_jsfield + int_oned_t;
    elseif any(f_strcmpi(coil_type,{'open_iscoil','open_vscoil'}))
        id_node_netrode = [id_node_netrode c3dobj.emdesign.(id_emdesign).coil.(id_phydom).netrode.id_node];
        id_node_petrode = [id_node_petrode c3dobj.emdesign.(id_emdesign).coil.(id_phydom).petrode.id_node];
    end
end
%--------------------------------------------------------------------------
int_onfa_js = c3dobj.mesh3d.(id_mesh3d).rot * t_jsfield;
jsv = f_field_wf(int_onfa_js,c3dobj.mesh3d.(id_mesh3d));
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = jsv;
figure
f_quiver(node,vf);

%--------------------------------------------------------------------------
% --- bsfield
a_bsfield = zeros(nb_edge,1);
for iec = 1:length(id_bsfield__)
    %----------------------------------------------------------------------
    wfbs = sparse(nb_face,1);
    %----------------------------------------------------------------------
    id_phydom = id_bsfield__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #bsfield',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).bsfield.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).bsfield.(id_phydom).wfbs;
    for i = 1:nbFa_inEl
        wfbs = wfbs + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = c3dobj.mesh3d.(id_mesh3d).rot.' * wfbs;
    rotrot = c3dobj.mesh3d.(id_mesh3d).rot.' * ...
             c3dobj.emdesign.(id_emdesign).matrix.wfwf * ...
             c3dobj.mesh3d.(id_mesh3d).rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = c3dobj.emdesign.(id_emdesign).matrix.id_edge_a;
    %id_edge_a_unknown = setdiff(id_edge_a_unknown,id_inner_edge_nomesh);
    %----------------------------------------------------------------------
    rotb = rotb(id_edge_a_unknown,1);
    rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
    %----------------------------------------------------------------------
    int_oned_a = zeros(nb_edge,1);
    int_oned_a(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
    %----------------------------------------------------------------------
    a_bsfield = a_bsfield + int_oned_a;
end
%--------------------------------------------------------------------------
int_onfa_b = c3dobj.mesh3d.(id_mesh3d).rot * a_bsfield;
bv = f_field_wf(int_onfa_b,c3dobj.mesh3d.(id_mesh3d));
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = bv;
figure
f_quiver(node,vf);

%--------------------------------------------------------------------------
% --- pmagnet
a_pmagnet = zeros(nb_edge,1);
for iec = 1:length(id_pmagnet__)
    %----------------------------------------------------------------------
    wfbr = sparse(nb_face,1);
    %----------------------------------------------------------------------
    id_phydom = id_pmagnet__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #pmagnet',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).pmagnet.(id_phydom).id_elem;
    lmatrix = c3dobj.emdesign.(id_emdesign).pmagnet.(id_phydom).wfbr;
    for i = 1:nbFa_inEl
        wfbr = wfbr + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = c3dobj.mesh3d.(id_mesh3d).rot.' * wfbr;
    rotrot = c3dobj.mesh3d.(id_mesh3d).rot.' * ...
             c3dobj.emdesign.(id_emdesign).matrix.wfwf * ...
             c3dobj.mesh3d.(id_mesh3d).rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = c3dobj.emdesign.(id_emdesign).matrix.id_edge_a;
    %id_edge_a_unknown = setdiff(id_edge_a_unknown,id_inner_edge_nomesh);
    %----------------------------------------------------------------------
    rotb = rotb(id_edge_a_unknown,1);
    rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
    %----------------------------------------------------------------------
    int_oned_a = zeros(nb_edge,1);
    int_oned_a(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
    %----------------------------------------------------------------------
    a_pmagnet = a_pmagnet + int_oned_a;
end
%--------------------------------------------------------------------------
int_onfa_b = c3dobj.mesh3d.(id_mesh3d).rot * a_pmagnet;
bv = f_field_wf(int_onfa_b,c3dobj.mesh3d.(id_mesh3d));
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = bv;
figure
f_quiver(node,vf);

%--------------------------------------------------------------------------
% --- sibc
gsibcwewe = sparse(nb_edge,nb_edge);
% ---
for iec = 1:length(id_bc__)
    %----------------------------------------------------------------------
    id_phydom = id_bc__{iec};
    bc_type = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).bc_type;
    if any(f_strcmpi(bc_type,'sibc'))
        %------------------------------------------------------------------
        f_fprintf(0,'--- #bc/sibc ',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        %id_face  = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).id_face;
        gid_face = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).gid_face;
        lid_face = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).lid_face;
        lmatrix  = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).gsibcwewe;
        %------------------------------------------------------------------
        for igr = 1:length(lmatrix)
            nbEd_inFa = size(lmatrix{igr},2);
            id_face = gid_face{igr};
            for i = 1:nbEd_inFa
                for j = i+1 : nbEd_inFa
                    gsibcwewe = gsibcwewe + ...
                        sparse(id_edge_in_face(i,id_face),id_edge_in_face(j,id_face),...
                               lmatrix{igr}(:,i,j),nb_edge,nb_edge);
                end
            end
        end
        %------------------------------------------------------------------
        id_node_phi = [id_node_phi ...
            c3dobj.emdesign.(id_emdesign).bc.(id_phydom).id_node_phi];
        %------------------------------------------------------------------
    end
end
% ---
gsibcwewe = gsibcwewe + gsibcwewe.';
% ---
for iec = 1:length(id_bc__)
    %----------------------------------------------------------------------
    id_phydom = id_bc__{iec};
    bc_type = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).bc_type;
    if any(f_strcmpi(bc_type,'sibc'))
        %------------------------------------------------------------------
        %id_face = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).id_face;
        gid_face = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).gid_face;
        lid_face = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).lid_face;
        lmatrix = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).gsibcwewe;
        %------------------------------------------------------------------
        for igr = 1:length(lmatrix)
            id_face = gid_face{igr};
            nbEd_inFa = size(lmatrix{igr},2);
            for i = 1:nbEd_inFa
                gsibcwewe = gsibcwewe + ...
                    sparse(id_edge_in_face(i,id_face),id_edge_in_face(i,id_face),...
                           lmatrix{igr}(:,i,i),nb_edge,nb_edge);
            end
        end
    end
end

%--------------------------------------------------------------------------
% --- bc-bsfield
% for iec = 1:length(id_bc__)
%     id_phydom = id_bc__{iec};
%     bc_type = c3dobj.emdesign.(id_emdesign).bc.(id_phydom).bc_type;
%     if any(f_strcmpi(bc_type,'bsfield'))
%     end
% end

% %--------------------------------------------------------------------------
% int_onfa_b = c3dobj.mesh3d.(id_mesh3d).rot * a_bc;
% bv = f_field_wf(int_onfa_b,c3dobj.mesh3d.(id_mesh3d));
% node = c3dobj.mesh3d.(id_mesh3d).celem;
% vf = bv;
% figure
% f_quiver(node,vf);



%--------------------------------------------------------------------------
%
%               MATRIX SYSTEM
%
%--------------------------------------------------------------------------
id_edge_a_unknown   = setdiff(id_inner_edge_airbox,id_inner_edge_nomesh);
id_node_phi_unknown = setdiff(id_node_phi,...
                   [id_inner_node_nomesh id_node_netrode id_node_petrode]);
% --- LSH
% --- nu0nurwfwf
id_elem_air = setdiff(id_elem_airbox,[id_elem_nomesh id_elem_mcon]);
id_face_in_elem_air = f_uniquenode(id_face_in_elem(:,id_elem_air));
mu0 = 4 * pi * 1e-7;
nu0wfwf = (1/mu0) .* c3dobj.emdesign.(id_emdesign).matrix.wfwfx;
% ---
nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) = ...
    nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) + ...
    nu0wfwf(id_face_in_elem_air,id_face_in_elem_air);
% ---
%nu0nurwfwf = nu0nurwfwf + nu0wfwf;
% ---
% nu0wfwf = (1/mu0) .* c3dobj.emdesign.(id_emdesign).matrix.wfwf;
% nu0nurwfwf = nu0wfwf;
% ---
sigmawewe = sigmawewe + gsibcwewe;
% ---
freq = c3dobj.emdesign.(id_emdesign).frequency;
jome = 1j*2*pi*freq;
S11  = c3dobj.mesh3d.(id_mesh3d).rot.' * nu0nurwfwf * c3dobj.mesh3d.(id_mesh3d).rot;
S11  = S11 + jome .* sigmawewe;
S12  = jome .* sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad;
S22  = jome .* c3dobj.mesh3d.(id_mesh3d).grad.' * sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad;
% --- dirichlet remove
S11 = S11(id_edge_a_unknown,id_edge_a_unknown);
S12 = S12(id_edge_a_unknown,:);
S12 = S12(:,id_node_phi_unknown);
S22 = S22(id_node_phi_unknown,id_node_phi_unknown);
% ---
LHS = S11;              clear S11;
LHS = [LHS  S12];
LHS = [LHS; S12.' S22]; clear S12 S22;

%--------------------------------------------------------------------------
% --- RHS
% bsfieldRHS = - c3dobj.mesh3d.(id_mesh3d).rot.' * ...
%                nu0nurwfwf * ...
%                c3dobj.mesh3d.(id_mesh3d).rot * a_bsfield;
% pmagnetRHS =   c3dobj.mesh3d.(id_mesh3d).rot.' * ...
%                nu0nurwfwf * ...
%                c3dobj.mesh3d.(id_mesh3d).rot * a_pmagnet;
% jscoilRHS  =   c3dobj.mesh3d.(id_mesh3d).rot.' * wewf.' * t_jsfield;
% ---
% bsfieldRHS = - c3dobj.mesh3d.(id_mesh3d).rot.' * ...
%                nu0wfwf * ...
%                c3dobj.mesh3d.(id_mesh3d).rot * a_bsfield;
% pmagnetRHS =   c3dobj.mesh3d.(id_mesh3d).rot.' * ...
%                nu0wfwf * ...
%                c3dobj.mesh3d.(id_mesh3d).rot * a_pmagnet;
% jscoilRHS  =   c3dobj.mesh3d.(id_mesh3d).rot.' * wewf.' * t_jsfield;
% ---
bsfieldRHS = - c3dobj.mesh3d.(id_mesh3d).rot.' * ...
               nu0nurwfwf * ...
               c3dobj.mesh3d.(id_mesh3d).rot * a_bsfield;
pmagnetRHS =   c3dobj.mesh3d.(id_mesh3d).rot.' * ...
               ((1/mu0).* c3dobj.emdesign.(id_emdesign).matrix.wfwf) * ...
               c3dobj.mesh3d.(id_mesh3d).rot * a_pmagnet;
jscoilRHS  =   c3dobj.mesh3d.(id_mesh3d).rot.' * wewf.' * t_jsfield;
%--------------------------------------------------------------------------
RHS = bsfieldRHS + pmagnetRHS + jscoilRHS;
RHS = RHS(id_edge_a_unknown,1);
RHS = [RHS; zeros(length(id_node_phi_unknown),1)];
%--------------------------------------------------------------------------
for iec = 1:length(id_coil__)
    %----------------------------------------------------------------------
    id_phydom = id_coil__{iec};
    coil_type = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).coil_type;
    if any(f_strcmpi(coil_type,{'open_iscoil'}))
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/iscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        alpha  = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).alpha;
        i_coil = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).i_coil;
        %------------------------------------------------------------------
        S13 = jome * (sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad * alpha);
        S23 = jome * (c3dobj.mesh3d.(id_mesh3d).grad.' * sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad * alpha);
        S33 = jome * (alpha.' * c3dobj.mesh3d.(id_mesh3d).grad.' * sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad * alpha);
        S13 = S13(id_edge_a_unknown,1);
        S23 = S23(id_node_phi_unknown,1);
        LHS = [LHS [S13;  S23]];
        LHS = [LHS; S13.' S23.' S33];
        RHS = [RHS; i_coil];

    elseif any(f_strcmpi(coil_type,{'open_vscoil'}))
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/vscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        Voltage  = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).v_petrode - ...
                   c3dobj.emdesign.(id_emdesign).coil.(id_phydom).v_netrode;
        alpha    = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).alpha;
        %------------------------------------------------------------------
        vRHSed = - sigmawewe * c3dobj.mesh3d.(id_mesh3d).grad * (alpha .* Voltage);
        vRHSed = vRHSed(id_edge_a_unknown);
        %------------------------------------------------------------------
        vRHSno = - c3dobj.mesh3d.(id_mesh3d).grad.'  * sigmawewe * ...
                   c3dobj.mesh3d.(id_mesh3d).grad * (alpha .* Voltage);
        vRHSno = vRHSno(id_node_phi_unknown);
        %------------------------------------------------------------------
        RHS = RHS + [vRHSed; vRHSno];
    end
end

%--------------------------------------------------------------------------
int_oned_a = zeros(nb_edge,1);
phiv = zeros(nb_node,1);
sol = f_solve_axb(LHS,RHS);
%--------------------------------------------------------------------------
len_sol = length(sol);
len_a_unknown = length(id_edge_a_unknown);
len_phi_unknown = length(id_node_phi_unknown);
%--------------------------------------------------------------------------
int_oned_a(id_edge_a_unknown) = sol(1:len_a_unknown);
phiv(id_node_phi_unknown)     = sol(len_a_unknown+1 : ...
                                    len_a_unknown+len_phi_unknown);
%--------------------------------------------------------------------------
if (len_a_unknown + len_phi_unknown) < len_sol
    dphiv = sol(len_a_unknown+len_phi_unknown+1 : len_sol);
end
%--------------------------------------------------------------------------
for iec = 1:length(id_coil__)
    %----------------------------------------------------------------------
    id_phydom = id_coil__{iec};
    coil_type = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).coil_type;
    %----------------------------------------------------------------------
    id_dphi = 0;
    if any(f_strcmpi(coil_type,{'open_iscoil'}))
        %------------------------------------------------------------------
        alpha  = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).alpha;
        i_coil = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).i_coil;
        %------------------------------------------------------------------
        id_dphi = id_dphi + 1;
        %------------------------------------------------------------------
        Voltage = jome .* dphiv(id_dphi);
        phiv = phiv + 1/jome .* (alpha .* Voltage);
        %------------------------------------------------------------------
        int_oned_e = -jome .* (int_oned_a + c3dobj.mesh3d.(id_mesh3d).grad * phiv);
        Current = -(sigmawewe * int_oned_e).' * (c3dobj.mesh3d.(id_mesh3d).grad * alpha);
        %------------------------------------------------------------------
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Voltage = Voltage;
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Current = Current;
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Z = Voltage/i_coil;
        %------------------------------------------------------------------
    elseif any(f_strcmpi(coil_type,{'open_vscoil'}))
        %------------------------------------------------------------------
        Voltage  = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).v_petrode - ...
                   c3dobj.emdesign.(id_emdesign).coil.(id_phydom).v_netrode;
        alpha    = c3dobj.emdesign.(id_emdesign).coil.(id_phydom).alpha;
        %------------------------------------------------------------------
        phiv = phiv + 1/jome .* (alpha .* Voltage);
        %------------------------------------------------------------------
        int_oned_e = -jome .* (int_oned_a + c3dobj.mesh3d.(id_mesh3d).grad * phiv);
        i_coil = -(sigmawewe * int_oned_e).' * (c3dobj.mesh3d.(id_mesh3d).grad * alpha);
        Current = i_coil;
        %------------------------------------------------------------------
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Voltage = Voltage;
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Current = Current;
        c3dobj.emdesign.(id_emdesign).coil.(id_phydom).Z = Voltage/Current;
    end
end






%--------------------------------------------------------------------------
av = f_field_we(int_oned_a,c3dobj.mesh3d.(id_mesh3d));
% ---
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = av;
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));
% ---
inode = find(c3dobj.mesh3d.(id_mesh3d).celem(3,:) > 0.02 & ...
             c3dobj.mesh3d.(id_mesh3d).celem(3,:) < 0.04);
node = c3dobj.mesh3d.(id_mesh3d).celem(:,inode);
vf = av(:,inode);
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));

%--------------------------------------------------------------------------
node = c3dobj.mesh3d.(id_mesh3d).node;
id_dom = 'plate_1_surface';
if isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_elem')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem)
        id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem;
        elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
        face = f_boundface(elem,node,'elem_type',elem_type);
    end
elseif isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_face')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face)
        id_face = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face;
        face = c3dobj.mesh3d.(id_mesh3d).face(:,id_face);
    end
end
sf   = imag(phiv);
% ---
id_face = 1:size(face,2);
% 1/ triangle
itria = find(face(end, id_face) == 0);
% 2/ quad
iquad = find(face(end, id_face) ~= 0);
% ---

figure
msh = [];
msh.Faces = face(1:3,itria).';
msh.Vertices = node.';
msh.FaceVertexCData = f_tocolv(sf);
msh.FaceColor = 'interp';
patch(msh); hold on
msh = [];
msh.Faces = face(1:4,iquad).';
msh.Vertices = node.';
msh.FaceVertexCData = f_tocolv(sf);
msh.FaceColor = 'interp';
patch(msh);
view(3);

%--------------------------------------------------------------------------
int_onfa_b = c3dobj.mesh3d.(id_mesh3d).rot * int_oned_a;
bv = f_field_wf(int_onfa_b,c3dobj.mesh3d.(id_mesh3d));
% ---
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = bv;
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));
% ---
inode = find(c3dobj.mesh3d.(id_mesh3d).celem(3,:) > 0.02 & ...
             c3dobj.mesh3d.(id_mesh3d).celem(3,:) < 0.04);
node = c3dobj.mesh3d.(id_mesh3d).celem(:,inode);
vf = bv(:,inode);
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));


%--------------------------------------------------------------------------
int_oned_e = -jome .* (int_oned_a + c3dobj.mesh3d.(id_mesh3d).grad * phiv);
%int_oned_e = -jome .* (int_oned_a);
%int_oned_e = -jome .* (c3dobj.mesh3d.(id_mesh3d).grad * phiv);
ev = f_field_we(int_oned_e,c3dobj.mesh3d.(id_mesh3d));
% ---
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = ev;
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));

%--------------------------------------------------------------------------
nb_face = size(c3dobj.mesh3d.(id_mesh3d).face,2);
es = sparse(2,nb_face);
js = sparse(2,nb_face);
id_edge_in_face = c3dobj.mesh3d.(id_mesh3d).id_edge_in_face;

%--------------------------------------------------------------------------
dom_name = 'sibc1';
sigma_array = c3dobj.emdesign.(id_emdesign).bc.(dom_name).sigma;
skindepth = c3dobj.emdesign.(id_emdesign).bc.(dom_name).skindepth;
facemesh = c3dobj.emdesign.(id_emdesign).bc.(dom_name).facemesh;
gid_face = c3dobj.emdesign.(id_emdesign).bc.(dom_name).gid_face;
lid_face = c3dobj.emdesign.(id_emdesign).bc.(dom_name).lid_face;
for i = 1:length(facemesh)
    face = facemesh{i}.elem;
    elem_type = facemesh{i}.elem_type;
    id_face = gid_face{i};
    cWes = facemesh{i}.intkit.cWe{1};
    if any(f_strcmpi(elem_type,'tri'))
        dofe = int_oned_e(id_edge_in_face(1:3,id_face)).';
    elseif any(f_strcmpi(elem_type,'quad'))
        dofe = int_oned_e(id_edge_in_face(1:4,id_face)).';
    end
    es(1,id_face) = es(1,id_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
    es(2,id_face) = es(2,id_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
    js(1,id_face) = sigma_array .* es(1,id_face);
    js(2,id_face) = sigma_array .* es(2,id_face);
end
%--------------------------------------------------------------------------
dom_name = 'sibc2';
sigma_array = c3dobj.emdesign.(id_emdesign).bc.(dom_name).sigma;
skindepth = c3dobj.emdesign.(id_emdesign).bc.(dom_name).skindepth;
facemesh = c3dobj.emdesign.(id_emdesign).bc.(dom_name).facemesh;
gid_face = c3dobj.emdesign.(id_emdesign).bc.(dom_name).gid_face;
lid_face = c3dobj.emdesign.(id_emdesign).bc.(dom_name).lid_face;
for i = 1:length(facemesh)
    face = facemesh{i}.elem;
    elem_type = facemesh{i}.elem_type;
    id_face = gid_face{i};
    cWes = facemesh{i}.intkit.cWe{1};
    if any(f_strcmpi(elem_type,'tri'))
        dofe = int_oned_e(id_edge_in_face(1:3,id_face)).';
    elseif any(f_strcmpi(elem_type,'quad'))
        dofe = int_oned_e(id_edge_in_face(1:4,id_face)).';
    end
    es(1,id_face) = es(1,id_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
    es(2,id_face) = es(2,id_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
    js(1,id_face) = sigma_array .* es(1,id_face);
    js(2,id_face) = sigma_array .* es(2,id_face);
end
%--------------------------------------------------------------------------
node = c3dobj.mesh3d.(id_mesh3d).node;
id_dom = 'plate_1_surface'; % 
if isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_elem')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem)
        id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem;
        elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
        face = f_boundface(elem,node,'elem_type',c3dobj.mesh3d.(id_mesh3d).elem_type);
        id_face = f_findvecnd(face, ...
                              c3dobj.mesh3d.(id_mesh3d).face);
    end
elseif isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_face')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face)
        id_face = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face;
        face = c3dobj.mesh3d.(id_mesh3d).face(:,id_face);
    end
end
sf   = f_magnitude(js);
% ---
% 1/ triangle
itria = find(face(end, :) == 0);
itria = id_face(itria);
% 2/ quad
iquad = find(face(end, :) ~= 0);
iquad = id_face(iquad);
% ---

figure
if ~isempty(itria)
    msh = [];
    msh.Faces = c3dobj.mesh3d.(id_mesh3d).face(1:3,itria).';
    msh.Vertices = node.';
    msh.FaceVertexCData = f_tocolv(full(sf(itria)));
    msh.FaceColor = 'flat';
    patch(msh); axis equal
    hold on
end
if ~isempty(iquad)
    msh = [];
    msh.Faces = c3dobj.mesh3d.(id_mesh3d).face(1:4,iquad).';
    msh.Vertices = node.';
    msh.FaceVertexCData = f_tocolv(full(sf(iquad)));
    msh.FaceColor = 'flat';
    patch(msh); axis equal
    hold on
end

%--------------------------------------------------------------------------
node = c3dobj.mesh3d.(id_mesh3d).node;
id_dom = 'coil_surface'; % 
if isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_elem')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem)
        id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_elem;
        elem = c3dobj.mesh3d.(id_mesh3d).elem(:,id_elem);
        face = f_boundface(elem,node,'elem_type',c3dobj.mesh3d.(id_mesh3d).elem_type);
        id_face = f_findvecnd(face, ...
                              c3dobj.mesh3d.(id_mesh3d).face);
    end
elseif isfield(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom),'id_face')
    if ~isempty(c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face)
        id_face = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom).id_face;
        face = c3dobj.mesh3d.(id_mesh3d).face(:,id_face);
    end
end
sf   = f_magnitude(js);
% ---
% 1/ triangle
itria = find(face(end, :) == 0);
itria = id_face(itria);
% 2/ quad
iquad = find(face(end, :) ~= 0);
iquad = id_face(iquad);
% ---

figure
if ~isempty(itria)
    msh = [];
    msh.Faces = c3dobj.mesh3d.(id_mesh3d).face(1:3,itria).';
    msh.Vertices = node.';
    msh.FaceVertexCData = f_tocolv(full(sf(itria)));
    msh.FaceColor = 'flat';
    patch(msh); axis equal
    hold on
end
if ~isempty(iquad)
    msh = [];
    msh.Faces = c3dobj.mesh3d.(id_mesh3d).face(1:4,iquad).';
    msh.Vertices = node.';
    msh.FaceVertexCData = f_tocolv(full(sf(iquad)));
    msh.FaceColor = 'flat';
    patch(msh); axis equal
    hold on
end

%--------------------------------------------------------------------------
jv = sparse(3,nb_elem);
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    id_elem = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem;
    sigma_array = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigma_array;
    %----------------------------------------------------------------------
    jv(:,id_elem) = f_cxvf(sigma_array,ev(:,id_elem));
end

% ---
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = jv;
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));


%--------------------------------------------------------------------------
jv = sparse(3,nb_elem);
%----------------------------------------------------------------------
id_phydom = 'plate_2';
%----------------------------------------------------------------------
id_elem = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem;
sigma_array = c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigma_array;
%----------------------------------------------------------------------
jv(:,id_elem) = f_cxvf(sigma_array,ev(:,id_elem));

% ---
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = jv;
figure
subplot(121)
f_quiver(node,real(vf));
subplot(122)
f_quiver(node,imag(vf));





%--------------------------------------------------------------------------
%--- Test symmetric
if issymmetric(sigmawewe)
    f_fprintf(0,'sigmawewe is symmetric \n');
end
if issymmetric(nu0nurwfwf)
    f_fprintf(0,'nu0nurwfwf is symmetric \n');
end
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');

end