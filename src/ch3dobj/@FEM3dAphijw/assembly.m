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

%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Assembly',1,class(obj),0,'\n');
%--------------------------------------------------------------------------
obj.build;
obj.base_matrix;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
if obj.assembly_done
    return
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
parent_mesh = obj.parent_mesh;
nb_elem = parent_mesh.nb_elem;
nb_face = parent_mesh.nb_face;
nb_edge = parent_mesh.nb_edge;
nb_node = parent_mesh.nb_node;
%--------------------------------------------------------------------------
obj.matrix.id_edge_a = 1:nb_edge;
obj.matrix.obj.matrix.sigmawewe = sparse(nb_edge,nb_edge);
obj.matrix.nu0nurwfwf = sparse(nb_face,nb_face);
%--------------------------------------------------------------------------
allowed_physical_dom = {'econductor','mconductor','airbox','sibc',...
                        'bsfield','coil','nomesh','pmagnet','embc'};
%--------------------------------------------------------------------------
for i = 1:length(allowed_physical_dom)
    phydom_type = allowed_physical_dom{i};
    % ---
    if isprop(obj,phydom_type)
        if isempty(obj.(phydom_type))
            continue
        end
    else
        continue
    end
    % ---
    allphydomid = fieldnames(obj.(phydom_type));
    for j = 1:length(allphydomid)
        id_phydom = allphydomid{j};
        phydom = obj.(phydom_type).(id_phydom);
        if isa(phydom,'IsCoilAphi') || isa(phydom,'VsCoilAphi')
            continue
        end
        % ---
        f_fprintf(0,['Assembly #' phydom_type],1,id_phydom,0,'\n');
        % ---
        phydom.assembly;
    end
end
%--------------------------------------------------------------------------
obj.assembly_done = 1;


%--------------------------------------------------------------------------
con = f_connexion(parent_mesh.elem_type);
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
id_edge_in_elem = parent_mesh.meshds.id_edge_in_elem;
id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
%--------------------------------------------------------------------------
% --- nomesh
id_elem_nomesh = obj.matrix.id_elem_nomesh;
id_inner_edge_nomesh = obj.matrix.id_inner_edge_nomesh;
id_inner_node_nomesh = obj.matrix.id_inner_node_nomesh;
%--------------------------------------------------------------------------
% --- airbox
id_elem_airbox = obj.matrix.id_elem_airbox;
id_inner_edge_airbox = obj.matrix.id_inner_edge_airbox;
%--------------------------------------------------------------------------
% --- mconductor

%--------------------------------------------------------------------------
% --- econductor

%--------------------------------------------------------------------------
% --- js-coil

%--------------------------------------------------------------------------
% --- bsfield

%--------------------------------------------------------------------------
% --- pmagnet

%--------------------------------------------------------------------------
% --- sibc

%--------------------------------------------------------------------------
%
%               MATRIX SYSTEM
%
%--------------------------------------------------------------------------
id_edge_a_unknown   = setdiff(id_inner_edge_airbox,id_inner_edge_nomesh);
id_node_phi_unknown = setdiff(id_node_phi,...
                   [id_inner_node_nomesh id_node_netrode id_node_petrode]);
% --- LSH
% --- obj.matrix.nu0nurwfwf
id_elem_air = setdiff(id_elem_airbox,[id_elem_nomesh id_elem_mcon]);
id_face_in_elem_air = f_uniquenode(id_face_in_elem(:,id_elem_air));
mu0 = 4 * pi * 1e-7;
nu0wfwf = (1/mu0) .* obj.matrix.wfwfx;
% ---
obj.matrix.nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) = ...
    obj.matrix.nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) + ...
    nu0wfwf(id_face_in_elem_air,id_face_in_elem_air);
% ---
obj.matrix.sigmawewe = obj.matrix.sigmawewe + gsibcwewe;
% ---
freq = obj.frequency;
jome = 1j*2*pi*freq;
S11  = obj.parent_mesh.discrete.rot.' * obj.matrix.nu0nurwfwf * obj.parent_mesh.discrete.rot;
S11  = S11 + jome .* obj.matrix.sigmawewe;
S12  = jome .* obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
S22  = jome .* obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
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
               obj.matrix.nu0nurwfwf * ...
               obj.parent_mesh.discrete.rot * obj.dof.a_bs;
pmagnetRHS =   obj.parent_mesh.discrete.rot.' * ...
               ((1/mu0).* obj.matrix.wfwf) * ...
               obj.parent_mesh.discrete.rot * obj.dof.a_pm;
jscoilRHS  =   obj.parent_mesh.discrete.rot.' * obj.matrix.wewf.' * obj.dof.t_js;
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
    if isa(coil,'IsCoilAphi')
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/iscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        alpha  = coil.matrix.alpha;
        i_coil = coil.matrix.i_coil;
        %------------------------------------------------------------------
        S13 = jome * (obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S23 = jome * (obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S33 = jome * (alpha.' * obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
        S13 = S13(id_edge_a_unknown,1);
        S23 = S23(id_node_phi_unknown,1);
        LHS = [LHS [S13;  S23]];
        LHS = [LHS; S13.' S23.' S33];
        RHS = [RHS; i_coil];
        %------------------------------------------------------------------
    elseif isa(coil,'VsCoilAphi')
        %------------------------------------------------------------------
        f_fprintf(0,'--- #coil/vscoil',1,id_phydom,0,'\n');
        %------------------------------------------------------------------
        Voltage  = coil.matrix.v_coil;
        alpha    = coil.matrix.alpha;
        %------------------------------------------------------------------
        vRHSed = - obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * (alpha .* Voltage);
        vRHSed = vRHSed(id_edge_a_unknown);
        %------------------------------------------------------------------
        vRHSno = - obj.parent_mesh.discrete.grad.'  * obj.matrix.sigmawewe * ...
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



