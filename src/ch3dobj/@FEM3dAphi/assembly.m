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
nb_elem = obj.nb_elem;
nb_face = obj.nb_face;
nb_edge = obj.nb_edge;
nb_node = obj.nb_node;
%--------------------------------------------------------------------------
% Do this first
obj.matrix.id_edge_a = 1:nb_edge;
id_edge_a = obj.matrix.id_edge_a;
%--------------------------------------------------------------------------
obj.build_nomesh;
obj.build_airbox;
obj.build_econductor;
obj.build_mconductor;
obj.build_bsfield;
obj.build_pmagnet;
obj.build_sibc;
obj.build_coil;
%--------------------------------------------------------------------------
id_econductor__ = {};
id_mconductor__ = {};
id_airbox__     = {};
id_sibc__         = {};
id_bsfield__    = {};
id_coil__       = {};
id_nomesh__     = {};
id_pmagnet__    = {};
% ---
if isfield(obj,'econductor')
    id_econductor__ = fieldnames(obj.econductor);
end
% ---
if isfield(obj,'mconductor')
    id_mconductor__ = fieldnames(obj.mconductor);
end
% ---
if isfield(obj,'airbox')
    id_airbox__ = fieldnames(obj.airbox);
end
% ---
if isfield(obj,'sibc')
    id_sibc__ = fieldnames(obj.sibc);
end
% ---
if isfield(obj,'bsfield')
    id_bsfield__ = fieldnames(obj.bsfield);
end
% ---
if isfield(obj,'coil')
    id_coil__ = fieldnames(obj.coil);
end
% ---
if isfield(obj,'nomesh')
    id_nomesh__ = fieldnames(obj.nomesh);
end
% ---
if isfield(obj,'pmagnet')
    id_pmagnet__ = fieldnames(obj.pmagnet);
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
    id_elem = obj.nomesh.(id_phydom).id_elem;
    id_inner_edge = obj.nomesh.(id_phydom).id_inner_edge;
    id_inner_node = obj.nomesh.(id_phydom).id_inner_node;
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
    id_elem = obj.mconductor.(id_phydom).id_elem;
    lmatrix = obj.mconductor.(id_phydom).nu0nurwfwf;
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
    id_elem = obj.mconductor.(id_phydom).id_elem;
    lmatrix = obj.mconductor.(id_phydom).nu0nurwfwf;
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
obj.matrix.wfwf  = wfwf;
obj.matrix.wfwfx = wfwfx;
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
obj.matrix.wewe  = wewe;
obj.matrix.wewex = wewex;
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
obj.matrix.wewf  = wewf;
obj.matrix.wewfx = wewfx;
%--------------------------------------------------------------------------
% --- airbox
id_phydom = id_airbox__{1};
f_fprintf(0,'--- #airbox',1,id_phydom,0,'\n');
id_elem_airbox = obj.airbox.(id_phydom).id_elem;
id_inner_edge_airbox = obj.airbox.(id_phydom).id_inner_edge;
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
    id_elem = obj.econductor.(id_phydom).id_elem;
    lmatrix = obj.econductor.(id_phydom).sigmawewe;
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
        obj.econductor.(id_phydom).id_node_phi];
    %----------------------------------------------------------------------
end
% ---
sigmawewe = sigmawewe + sigmawewe.';
% ---
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    id_elem = obj.econductor.(id_phydom).id_elem;
    lmatrix = obj.econductor.(id_phydom).sigmawewe;
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
    coil_type = obj.coil.(id_phydom).coil_type;
    if any(f_strcmpi(coil_type,{'close_jscoil','open_jscoil'}))
        %----------------------------------------------------------------------
        f_fprintf(0,'--- #coil/jscoil',1,id_phydom,0,'\n');
        %----------------------------------------------------------------------
        id_elem = obj.coil.(id_phydom).id_elem;
        lmatrix = obj.coil.(id_phydom).wfjs;
        for i = 1:nbFa_inEl
            wfjs = wfjs + ...
                   sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
        end
        %----------------------------------------------------------------------
        rotj = obj.discrete.rot.' * wfjs;
        rotrot = obj.discrete.rot.' * ...
                 obj.matrix.wfwf * ...
                 obj.discrete.rot;
        %----------------------------------------------------------------------
        id_edge_t_unknown = obj.matrix.id_edge_a;
        %----------------------------------------------------------------------
        rotj = rotj(id_edge_t_unknown,1);
        rotrot = rotrot(id_edge_t_unknown,id_edge_t_unknown);
        %----------------------------------------------------------------------
        int_oned_t = zeros(nb_edge,1);
        int_oned_t(id_edge_t_unknown) = f_solve_axb(rotrot,rotj);
        %----------------------------------------------------------------------
        t_jsfield = t_jsfield + int_oned_t;
    elseif any(f_strcmpi(coil_type,{'open_iscoil','open_vscoil'}))
        id_node_netrode = [id_node_netrode obj.coil.(id_phydom).netrode.id_node];
        id_node_petrode = [id_node_petrode obj.coil.(id_phydom).petrode.id_node];
    end
end
%--------------------------------------------------------------------------
int_onfa_js = obj.discrete.rot * t_jsfield;
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
    id_elem = obj.bsfield.(id_phydom).id_elem;
    lmatrix = obj.bsfield.(id_phydom).wfbs;
    for i = 1:nbFa_inEl
        wfbs = wfbs + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = obj.discrete.rot.' * wfbs;
    rotrot = obj.discrete.rot.' * ...
             obj.matrix.wfwf * ...
             obj.discrete.rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = obj.matrix.id_edge_a;
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
int_onfa_b = obj.discrete.rot * a_bsfield;
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
    id_elem = obj.pmagnet.(id_phydom).id_elem;
    lmatrix = obj.pmagnet.(id_phydom).wfbr;
    for i = 1:nbFa_inEl
        wfbr = wfbr + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = obj.discrete.rot.' * wfbr;
    rotrot = obj.discrete.rot.' * ...
             obj.matrix.wfwf * ...
             obj.discrete.rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = obj.matrix.id_edge_a;
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
int_onfa_b = obj.discrete.rot * a_pmagnet;
bv = f_field_wf(int_onfa_b,c3dobj.mesh3d.(id_mesh3d));
node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = bv;
figure
f_quiver(node,vf);

%--------------------------------------------------------------------------
% --- sibc
gsibcwewe = sparse(nb_edge,nb_edge);
% ---
for iec = 1:length(id_sibc__)
    %----------------------------------------------------------------------
    id_phydom = id_sibc__{iec};


        %------------------------------------------------------------------
        f_fprintf(0,'--- #bc/sibc ',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        %id_face  = obj.bc.(id_phydom).id_face;
        gid_face = obj.bc.(id_phydom).gid_face;
        lid_face = obj.bc.(id_phydom).lid_face;
        lmatrix  = obj.bc.(id_phydom).gsibcwewe;
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
            obj.bc.(id_phydom).id_node_phi];
        %------------------------------------------------------------------
    
end
% ---
gsibcwewe = gsibcwewe + gsibcwewe.';
% ---
for iec = 1:length(id_sibc__)
    %----------------------------------------------------------------------
    id_phydom = id_sibc__{iec};
    bc_type = obj.bc.(id_phydom).bc_type;
    if any(f_strcmpi(bc_type,'sibc'))
        %------------------------------------------------------------------
        %id_face = obj.bc.(id_phydom).id_face;
        gid_face = obj.bc.(id_phydom).gid_face;
        lid_face = obj.bc.(id_phydom).lid_face;
        lmatrix = obj.bc.(id_phydom).gsibcwewe;
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
%     bc_type = obj.bc.(id_phydom).bc_type;
%     if any(f_strcmpi(bc_type,'bsfield'))
%     end
% end

% %--------------------------------------------------------------------------
% int_onfa_b = obj.discrete.rot * a_bc;
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
nu0wfwf = (1/mu0) .* obj.matrix.wfwfx;
% ---
nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) = ...
    nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) + ...
    nu0wfwf(id_face_in_elem_air,id_face_in_elem_air);
% ---
%nu0nurwfwf = nu0nurwfwf + nu0wfwf;
% ---
% nu0wfwf = (1/mu0) .* obj.matrix.wfwf;
% nu0nurwfwf = nu0wfwf;
% ---
sigmawewe = sigmawewe + gsibcwewe;
% ---
freq = obj.frequency;
jome = 1j*2*pi*freq;
S11  = obj.discrete.rot.' * nu0nurwfwf * obj.discrete.rot;
S11  = S11 + jome .* sigmawewe;
S12  = jome .* sigmawewe * obj.discrete.grad;
S22  = jome .* obj.discrete.grad.' * sigmawewe * obj.discrete.grad;
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
% bsfieldRHS = - obj.discrete.rot.' * ...
%                nu0nurwfwf * ...
%                obj.discrete.rot * a_bsfield;
% pmagnetRHS =   obj.discrete.rot.' * ...
%                nu0nurwfwf * ...
%                obj.discrete.rot * a_pmagnet;
% jscoilRHS  =   obj.discrete.rot.' * wewf.' * t_jsfield;
% ---
% bsfieldRHS = - obj.discrete.rot.' * ...
%                nu0wfwf * ...
%                obj.discrete.rot * a_bsfield;
% pmagnetRHS =   obj.discrete.rot.' * ...
%                nu0wfwf * ...
%                obj.discrete.rot * a_pmagnet;
% jscoilRHS  =   obj.discrete.rot.' * wewf.' * t_jsfield;
% ---
bsfieldRHS = - obj.discrete.rot.' * ...
               nu0nurwfwf * ...
               obj.discrete.rot * a_bsfield;
pmagnetRHS =   obj.discrete.rot.' * ...
               ((1/mu0).* obj.matrix.wfwf) * ...
               obj.discrete.rot * a_pmagnet;
jscoilRHS  =   obj.discrete.rot.' * wewf.' * t_jsfield;
%--------------------------------------------------------------------------
RHS = bsfieldRHS + pmagnetRHS + jscoilRHS;
RHS = RHS(id_edge_a_unknown,1);
RHS = [RHS; zeros(length(id_node_phi_unknown),1)];
%--------------------------------------------------------------------------
for iec = 1:length(id_coil__)
    %----------------------------------------------------------------------
    id_phydom = id_coil__{iec};
    coil_type = obj.coil.(id_phydom).coil_type;
    if any(f_strcmpi(coil_type,{'open_iscoil'}))
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/iscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        alpha  = obj.coil.(id_phydom).alpha;
        i_coil = obj.coil.(id_phydom).i_coil;
        %------------------------------------------------------------------
        S13 = jome * (sigmawewe * obj.discrete.grad * alpha);
        S23 = jome * (obj.discrete.grad.' * sigmawewe * obj.discrete.grad * alpha);
        S33 = jome * (alpha.' * obj.discrete.grad.' * sigmawewe * obj.discrete.grad * alpha);
        S13 = S13(id_edge_a_unknown,1);
        S23 = S23(id_node_phi_unknown,1);
        LHS = [LHS [S13;  S23]];
        LHS = [LHS; S13.' S23.' S33];
        RHS = [RHS; i_coil];

    elseif any(f_strcmpi(coil_type,{'open_vscoil'}))
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/vscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        Voltage  = obj.coil.(id_phydom).v_petrode - ...
                   obj.coil.(id_phydom).v_netrode;
        alpha    = obj.coil.(id_phydom).alpha;
        %------------------------------------------------------------------
        vRHSed = - sigmawewe * obj.discrete.grad * (alpha .* Voltage);
        vRHSed = vRHSed(id_edge_a_unknown);
        %------------------------------------------------------------------
        vRHSno = - obj.discrete.grad.'  * sigmawewe * ...
                   obj.discrete.grad * (alpha .* Voltage);
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
    coil_type = obj.coil.(id_phydom).coil_type;
    %----------------------------------------------------------------------
    id_dphi = 0;
    if any(f_strcmpi(coil_type,{'open_iscoil'}))
        %------------------------------------------------------------------
        alpha  = obj.coil.(id_phydom).alpha;
        i_coil = obj.coil.(id_phydom).i_coil;
        %------------------------------------------------------------------
        id_dphi = id_dphi + 1;
        %------------------------------------------------------------------
        Voltage = jome .* dphiv(id_dphi);
        phiv = phiv + 1/jome .* (alpha .* Voltage);
        %------------------------------------------------------------------
        int_oned_e = -jome .* (int_oned_a + obj.discrete.grad * phiv);
        Current = -(sigmawewe * int_oned_e).' * (obj.discrete.grad * alpha);
        %------------------------------------------------------------------
        obj.coil.(id_phydom).Voltage = Voltage;
        obj.coil.(id_phydom).Current = Current;
        obj.coil.(id_phydom).Z = Voltage/i_coil;
        %------------------------------------------------------------------
    elseif any(f_strcmpi(coil_type,{'open_vscoil'}))
        %------------------------------------------------------------------
        Voltage  = obj.coil.(id_phydom).v_petrode - ...
                   obj.coil.(id_phydom).v_netrode;
        alpha    = obj.coil.(id_phydom).alpha;
        %------------------------------------------------------------------
        phiv = phiv + 1/jome .* (alpha .* Voltage);
        %------------------------------------------------------------------
        int_oned_e = -jome .* (int_oned_a + obj.discrete.grad * phiv);
        i_coil = -(sigmawewe * int_oned_e).' * (obj.discrete.grad * alpha);
        Current = i_coil;
        %------------------------------------------------------------------
        obj.coil.(id_phydom).Voltage = Voltage;
        obj.coil.(id_phydom).Current = Current;
        obj.coil.(id_phydom).Z = Voltage/Current;
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
int_onfa_b = obj.discrete.rot * int_oned_a;
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
int_oned_e = -jome .* (int_oned_a + obj.discrete.grad * phiv);
%int_oned_e = -jome .* (int_oned_a);
%int_oned_e = -jome .* (obj.discrete.grad * phiv);
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
sigma_array = obj.bc.(dom_name).sigma;
skindepth = obj.bc.(dom_name).skindepth;
facemesh = obj.bc.(dom_name).facemesh;
gid_face = obj.bc.(dom_name).gid_face;
lid_face = obj.bc.(dom_name).lid_face;
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
sigma_array = obj.bc.(dom_name).sigma;
skindepth = obj.bc.(dom_name).skindepth;
facemesh = obj.bc.(dom_name).facemesh;
gid_face = obj.bc.(dom_name).gid_face;
lid_face = obj.bc.(dom_name).lid_face;
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
    id_elem = obj.econductor.(id_phydom).id_elem;
    sigma_array = obj.econductor.(id_phydom).sigma_array;
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
id_elem = obj.econductor.(id_phydom).id_elem;
sigma_array = obj.econductor.(id_phydom).sigma_array;
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