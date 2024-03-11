%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function solve(obj)

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
nb_elem = parent_mesh.nb_elem;
nb_face = parent_mesh.nb_face;
nb_edge = parent_mesh.nb_edge;
nb_node = parent_mesh.nb_node;
%--------------------------------------------------------------------------
obj.matrix.id_edge_a = 1:nb_edge;
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
id_sibc__       = {};
id_bsfield__    = {};
id_coil__       = {};
id_nomesh__     = {};
id_pmagnet__    = {};
% ---
if ~isempty(obj.econductor)
    id_econductor__ = fieldnames(obj.econductor);
end
% ---
if ~isempty(obj.mconductor)
    id_mconductor__ = fieldnames(obj.mconductor);
end
% ---
if ~isempty(obj.airbox)
    id_airbox__ = fieldnames(obj.airbox);
end
% ---
if ~isempty(obj.sibc)
    id_sibc__ = fieldnames(obj.sibc);
end
% ---
if ~isempty(obj.bsfield)
    id_bsfield__ = fieldnames(obj.bsfield);
end
% ---
if ~isempty(obj.coil)
    id_coil__ = fieldnames(obj.coil);
end
% ---
if ~isempty(obj.nomesh)
    id_nomesh__ = fieldnames(obj.nomesh);
end
% ---
if ~isempty(obj.pmagnet)
    id_pmagnet__ = fieldnames(obj.pmagnet);
end
%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Assembly',1,class(obj),0,'\n');
%--------------------------------------------------------------------------
con = f_connexion(parent_mesh.elem_type);
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
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
    id_elem = obj.mconductor.(id_phydom).matrix.gid_elem;
    lmatrix = obj.mconductor.(id_phydom).matrix.nu0nurwfwf;
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
    id_elem = obj.mconductor.(id_phydom).matrix.gid_elem;
    lmatrix = obj.mconductor.(id_phydom).matrix.nu0nurwfwf;
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
% --- airbox
id_phydom = id_airbox__{1};
f_fprintf(0,'--- #airbox',1,id_phydom,0,'\n');
id_elem_airbox = obj.airbox.(id_phydom).matrix.gid_elem;
id_inner_edge_airbox = obj.airbox.(id_phydom).matrix.gid_inner_edge;
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
    id_elem = obj.econductor.(id_phydom).matrix.gid_elem;
    lmatrix = obj.econductor.(id_phydom).matrix.sigmawewe;
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
        obj.econductor.(id_phydom).matrix.gid_node_phi];
    %----------------------------------------------------------------------
end
% ---
sigmawewe = sigmawewe + sigmawewe.';
% ---
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    id_elem = obj.econductor.(id_phydom).matrix.gid_elem;
    lmatrix = obj.econductor.(id_phydom).matrix.sigmawewe;
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
    coil = obj.coil.(id_phydom);
    %----------------------------------------------------------------------
    if isa(coil,'OpenJsCoil') || ...
       isa(coil,'CloseJsCoil')
        %----------------------------------------------------------------------
        f_fprintf(0,'--- #coil/jscoil',1,id_phydom,0,'\n');
        %----------------------------------------------------------------------
        id_elem = coil.matrix.gid_elem;
        lmatrix = coil.matrix.wfjs;
        for i = 1:nbFa_inEl
            wfjs = wfjs + ...
                   sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
        end
        %----------------------------------------------------------------------
        rotj = obj.parent_mesh.discrete.rot.' * wfjs;
        rotrot = obj.parent_mesh.discrete.rot.' * ...
                 obj.matrix.wfwf * ...
                 obj.parent_mesh.discrete.rot;
        %----------------------------------------------------------------------
        id_edge_t_unknown = obj.matrix.id_edge_a;
        %----------------------------------------------------------------------
        rotj = rotj(id_edge_t_unknown,1);
        rotrot = rotrot(id_edge_t_unknown,id_edge_t_unknown);
        %----------------------------------------------------------------------
        int_oned_t = zeros(nb_edge,1);
        int_oned_t(id_edge_t_unknown) = f_solve_axb(rotrot,rotj);
        clear rotj rotrot
        %----------------------------------------------------------------------
        t_jsfield = t_jsfield + int_oned_t;
    elseif isa(coil,'OpenIsCoil') || ...
           isa(coil,'OpenVsCoil')
        id_node_netrode = [id_node_netrode obj.coil.(id_phydom).netrode.id_node];
        id_node_petrode = [id_node_petrode obj.coil.(id_phydom).petrode.id_node];
    end
end
%--------------------------------------------------------------------------
clear wfjs
%--------------------------------------------------------------------------
obj.dof.t_js = t_jsfield;
obj.dof.js   = obj.parent_mesh.discrete.rot * t_jsfield;
obj.matrix.js  = obj.parent_mesh.field_wf('dof',obj.dof.js);
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
    id_elem = obj.bsfield.(id_phydom).matrix.gid_elem;
    lmatrix = obj.bsfield.(id_phydom).matrix.wfbs;
    for i = 1:nbFa_inEl
        wfbs = wfbs + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = obj.parent_mesh.discrete.rot.' * wfbs;
    rotrot = obj.parent_mesh.discrete.rot.' * ...
             obj.matrix.wfwf * ...
             obj.parent_mesh.discrete.rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = obj.matrix.id_edge_a;
    %----------------------------------------------------------------------
    rotb = rotb(id_edge_a_unknown,1);
    rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
    %----------------------------------------------------------------------
    int_oned_a = zeros(nb_edge,1);
    int_oned_a(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
    clear rotb rotrot
    %----------------------------------------------------------------------
    a_bsfield = a_bsfield + int_oned_a;
end
%--------------------------------------------------------------------------
obj.dof.a_bs = a_bsfield;
obj.dof.bs   = obj.parent_mesh.discrete.rot * a_bsfield;
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
    id_elem = obj.pmagnet.(id_phydom).matrix.gid_elem;
    lmatrix = obj.pmagnet.(id_phydom).matrix.wfbr;
    for i = 1:nbFa_inEl
        wfbr = wfbr + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = obj.parent_mesh.discrete.rot.' * wfbr;
    rotrot = obj.parent_mesh.discrete.rot.' * ...
             obj.matrix.wfwf * ...
             obj.parent_mesh.discrete.rot;
    %----------------------------------------------------------------------
    id_edge_a_unknown = obj.matrix.id_edge_a;
    %----------------------------------------------------------------------
    rotb = rotb(id_edge_a_unknown,1);
    rotrot = rotrot(id_edge_a_unknown,id_edge_a_unknown);
    %----------------------------------------------------------------------
    int_oned_a = zeros(nb_edge,1);
    int_oned_a(id_edge_a_unknown) = f_solve_axb(rotrot,rotb);
    clear rotb rotrot
    %----------------------------------------------------------------------
    a_pmagnet = a_pmagnet + int_oned_a;
end
%--------------------------------------------------------------------------
obj.dof.a_pm = a_pmagnet;
obj.dof.bpm  = obj.parent_mesh.discrete.rot * a_pmagnet;
%--------------------------------------------------------------------------
% --- sibc
gsibcwewe = sparse(nb_edge,nb_edge);
% ---
for iec = 1:length(id_sibc__)
    %----------------------------------------------------------------------
    id_phydom = id_sibc__{iec};
    sibc = obj.sibc.(id_phydom);
    %------------------------------------------------------------------
    f_fprintf(0,'--- #sibc ',1,id_phydom,0,'\n');
    %------------------------------------------------------------------
    gid_face = sibc.matrix.gid_face;
    lmatrix  = sibc.matrix.gsibcwewe;
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
        sibc.matrix.id_node_phi];
    %------------------------------------------------------------------
end
% ---
gsibcwewe = gsibcwewe + gsibcwewe.';
% ---
for iec = 1:length(id_sibc__)
    %----------------------------------------------------------------------
    id_phydom = id_sibc__{iec};
    sibc = obj.sibc.(id_phydom);
    %----------------------------------------------------------------------
    gid_face = sibc.matrix.gid_face;
    lmatrix  = sibc.matrix.gsibcwewe;
    %----------------------------------------------------------------------
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
sigmawewe = sigmawewe + gsibcwewe;
% ---
freq = obj.frequency;
jome = 1j*2*pi*freq;
S11  = obj.parent_mesh.discrete.rot.' * nu0nurwfwf * obj.parent_mesh.discrete.rot;
S11  = S11 + jome .* sigmawewe;
S12  = jome .* sigmawewe * obj.parent_mesh.discrete.grad;
S22  = jome .* obj.parent_mesh.discrete.grad.' * sigmawewe * obj.parent_mesh.discrete.grad;
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
bsfieldRHS = - obj.parent_mesh.discrete.rot.' * ...
               nu0nurwfwf * ...
               obj.parent_mesh.discrete.rot * obj.dof.a_bs;
pmagnetRHS =   obj.parent_mesh.discrete.rot.' * ...
               ((1/mu0).* obj.matrix.wfwf) * ...
               obj.parent_mesh.discrete.rot * obj.dof.a_pm;
jscoilRHS  =   obj.parent_mesh.discrete.rot.' * obj.matrix.wewf.' * t_jsfield;
%--------------------------------------------------------------------------
RHS = bsfieldRHS + pmagnetRHS + jscoilRHS;
RHS = RHS(id_edge_a_unknown,1);
RHS = [RHS; zeros(length(id_node_phi_unknown),1)];
%--------------------------------------------------------------------------
for iec = 1:length(id_coil__)
    %----------------------------------------------------------------------
    id_phydom = id_coil__{iec};
    coil = obj.coil.(id_phydom);
    %----------------------------------------------------------------------
    if isa(coil,'OpenIsCoil')
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/iscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        alpha  = coil.matrix.alpha;
        i_coil = coil.matrix.i_coil;
        %------------------------------------------------------------------
        S13 = jome * (sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S23 = jome * (obj.parent_mesh.discrete.grad.' * sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S33 = jome * (alpha.' * obj.parent_mesh.discrete.grad.' * sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S13 = S13(id_edge_a_unknown,1);
        S23 = S23(id_node_phi_unknown,1);
        LHS = [LHS [S13;  S23]];
        LHS = [LHS; S13.' S23.' S33];
        RHS = [RHS; i_coil];
        %------------------------------------------------------------------
    elseif isa(coil,'OpenVsCoil')
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/vscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        Voltage  = coil.matrix.v_petrode - ...
                   coil.matrix.v_netrode;
        alpha    = coil.matrix.alpha;
        %------------------------------------------------------------------
        vRHSed = - sigmawewe * obj.parent_mesh.discrete.grad * (alpha .* Voltage);
        vRHSed = vRHSed(id_edge_a_unknown);
        %------------------------------------------------------------------
        vRHSno = - obj.parent_mesh.discrete.grad.'  * sigmawewe * ...
                   obj.parent_mesh.discrete.grad * (alpha .* Voltage);
        vRHSno = vRHSno(id_node_phi_unknown);
        %------------------------------------------------------------------
        RHS = RHS + [vRHSed; vRHSno];
    end
end

%--------------------------------------------------------------------------
sol = f_solve_axb(LHS,RHS);
%--------------------------------------------------------------------------
len_sol = length(sol);
len_a_unknown = length(id_edge_a_unknown);
len_phi_unknown = length(id_node_phi_unknown);
%--------------------------------------------------------------------------
obj.dof.a   = zeros(nb_edge,1);
obj.dof.phi = zeros(nb_node,1);
obj.dof.a(id_edge_a_unknown)     = sol(1:len_a_unknown);
obj.dof.phi(id_node_phi_unknown) = sol(len_a_unknown+1 : ...
                                    len_a_unknown+len_phi_unknown);
%--------------------------------------------------------------------------
if (len_a_unknown + len_phi_unknown) < len_sol
    obj.dof.dphiv = sol(len_a_unknown+len_phi_unknown+1 : len_sol);
end
%--------------------------------------------------------------------------
obj.dof.b = obj.parent_mesh.discrete.rot * obj.dof.a;
obj.dof.e = -jome .* (obj.dof.a + obj.parent_mesh.discrete.grad * obj.dof.phi);
%--------------------------------------------------------------------------
obj.fields.bv = obj.parent_mesh.field_wf('dof',obj.dof.b);
obj.fields.ev = obj.parent_mesh.field_we('dof',obj.dof.e);
obj.fields.phiv = obj.dof.phi;

% ---
obj.fields.jv = sparse(3,nb_elem);
% ---
for iec = 1:length(id_econductor__)
    %----------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %----------------------------------------------------------------------
    [coefficient, coef_array_type] = ...
        obj.column_format(obj.econductor.(id_phydom).matrix.sigma_array);
    %----------------------------------------------------------------------
    id_elem = obj.econductor.(id_phydom).matrix.gid_elem;
    %----------------------------------------------------------------------
    if any(f_strcmpi(coef_array_type,{'scalar'}))
        %------------------------------------------------------------------
        obj.fields.jv(:,id_elem) = coefficient .* obj.fields.ev(:,id_elem);
        %------------------------------------------------------------------
    elseif any(f_strcmpi(coef_array_type,{'tensor'}))
        %------------------------------------------------------------------
        obj.fields.jv(1,id_elem) = coefficient(:,1,1).' .* obj.fields.ev(1,id_elem) + ...
                                   coefficient(:,1,2).' .* obj.fields.ev(2,id_elem) + ...
                                   coefficient(:,1,3).' .* obj.fields.ev(3,id_elem);
        obj.fields.jv(2,id_elem) = coefficient(:,2,1).' .* obj.fields.ev(1,id_elem) + ...
                                   coefficient(:,2,2).' .* obj.fields.ev(2,id_elem) + ...
                                   coefficient(:,2,3).' .* obj.fields.ev(3,id_elem);
        obj.fields.jv(3,id_elem) = coefficient(:,3,1).' .* obj.fields.ev(1,id_elem) + ...
                                   coefficient(:,3,2).' .* obj.fields.ev(2,id_elem) + ...
                                   coefficient(:,3,3).' .* obj.fields.ev(3,id_elem);
    end
end

% ---
es = sparse(2,nb_face);
js = sparse(2,nb_face);
for iec = 1:length(id_sibc__)
    %----------------------------------------------------------------------
    id_phydom = id_sibc__{iec};
    phydom = obj.sibc.(id_phydom);
    dom = phydom.dom;
    %----------------------------------------------------------------------
    sigma_array  = phydom.sigma.get_on(dom);
    % ---
    dom.build_submesh;
    submesh = dom.submesh;
    for k = 1:length(submesh)
        sm = submesh{k};
        sm.build_intkit;
        % ---
        id_face = sm.gid_face;
        cWes = sm.intkit.cWe{1};
        % ---
        if any(f_strcmpi(sm.elem_type,'tri'))
            dofe = obj.dof.e(id_edge_in_face(1:3,id_face)).';
        elseif any(f_strcmpi(sm.elem_type,'quad'))
            dofe = obj.dof.e(id_edge_in_face(1:4,id_face)).';
        end
        %------------------------------------------------------------------
        es(1,id_face) = es(1,id_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
        es(2,id_face) = es(2,id_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
        js(1,id_face) = sigma_array .* es(1,id_face);
        js(2,id_face) = sigma_array .* es(2,id_face);
    end
end
% -------------------------------------------------------------------------
obj.fields.js = js;
obj.fields.es = es;



