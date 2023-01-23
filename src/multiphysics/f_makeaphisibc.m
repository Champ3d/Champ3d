function System = f_makeaphisibc(dom3d,options)
% F_MAKEAPHISIBC returns the matrix system related to A-\phi sibc formulation. 
%--------------------------------------------------------------------------
% System = F_MAKEAPHISIBC(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

System.formulation = options.formulation;
System.fr = options.fr;

nbElem = dom3d.mesh.nbElem;
nbEdge = dom3d.mesh.nbEdge;
nbFace = dom3d.mesh.nbFace;
con = f_connexion(dom3d.mesh.elem_type);

%--------------------------------------------------------------------------
SWeWe = sparse(nbEdge,nbEdge);
iNoPhi = [];
if isfield(dom3d,'econductor')
    nb_dom = length(dom3d.econductor);
    for i = 1:nb_dom
        %---------------------------------------------
        iNoPhi = [iNoPhi reshape(dom3d.mesh.elem(1:con.nbNo_inEl,dom3d.econductor(i).id_elem),...
                                 1,con.nbNo_inEl*length(dom3d.econductor(i).id_elem))];
        %---------------------------------------------
        SWeWe = SWeWe + ...
                f_coefWeWe(dom3d.mesh,'coef',dom3d.econductor(i).gtensor,...
                  'id_elem',dom3d.econductor(i).id_elem,'elem_type',dom3d.mesh.elem_type);
    end
    iNoPhi(iNoPhi == 0) = [];
    iNoPhi = unique(iNoPhi);
end
System.id_node_phi = iNoPhi;

%--------------------------------------------------------------------------
SWfWf  = sparse(nbFace,nbFace);
mu0 = 4*pi*1e-7;
id_elem_mc = [];
if isfield(dom3d,'mconductor')
    nb_dom = length(dom3d.mconductor);
    for i = 1:nb_dom
        nu = inv(mu0 .* dom3d.mconductor(i).gtensor);
        SWfWf = SWfWf + ...
                f_coefWfWf(dom3d.mesh,'coef',nu,...
                  'id_elem',dom3d.mconductor(i).id_elem,'elem_type',dom3d.mesh.elem_type);
        id_elem_mc = [id_elem_mc dom3d.mconductor(i).id_elem];
    end
end

id_elem_vacumm = setdiff(1:nbElem,id_elem_mc);
SWfWf = SWfWf + ...
        f_coefWfWf(dom3d.mesh,'coef',1/mu0,...
          'id_elem',id_elem_vacumm,'elem_type',dom3d.mesh.elem_type);
%--------------------------------------------------------------------------
%---------------------- Source - RHS --------------------------------------
coilRHS = zeros(nbEdge,1);
if isfield(dom3d,'coil')
    coilRHS = f_makecoil(dom3d);
end
%--------------------------------------------------------------------------
%---------------------- Matrix system -------------------------------------
K11 = dom3d.mesh.R.' * SWfWf * dom3d.mesh.R;
K11 = K11 + (1j*2*pi*options.fr) .* SWeWe;
K12 = (1j*2*pi*options.fr) .* (SWeWe * dom3d.mesh.G);
K22 = (1j*2*pi*options.fr) .* (dom3d.mesh.G.' * SWeWe * dom3d.mesh.G);

%--------------------------------------------------------------------------
%---------------------- Boundary condition --------------------------------
iEdAfixed = [];
fixedRHS = zeros(nbEdge,1);
%-----
if isfield(options,'id_bcon_a')
    nb_bcon = length(options.id_bcon_a);
    for i = 1:nb_bcon
        switch lower(dom3d.bcon(i).bc_type)
            case 'fixed'
                iEdAfixed = [iEdAfixed dom3d.bcon(i).id_edge];
                X = zeros(nbEdge,1);
                if dom3d.bcon(i).bc_value ~= 0
                    X(dom3d.bcon(i).id_edge) = dom3d.bcon(i).bc_value;
                    fixedRHS = fixedRHS + K11 * X;
                end
            case 'xxx'
        end
    end
end
%-----
if isfield(options,'id_bcon_sibc')
    nb_bcon = length(options.id_bcon_sibc);
    for i = 1:nb_bcon
        switch lower(dom3d.bcon(i).bc_type)
            case 'fixed'
                iEdAfixed = [iEdAfixed dom3d.bcon(i).id_edge];
                X = zeros(nbEdge,1);
                if dom3d.bcon(i).bc_value ~= 0
                    X(dom3d.bcon(i).id_edge) = dom3d.bcon(i).bc_value;
                    fixedRHS = fixedRHS + K11 * X;
                end
            case 'xxx'
        end
    end
end
%-----
iEdA = setdiff(1:nbEdge,iEdAfixed);
iEdA(iEdA == 0) = [];
iEdA = unique(iEdA);
System.id_edge_a = iEdA;

% dirichlet remove
K11 = K11(iEdA,iEdA);
K12 = K12(iEdA,:);
K12 = K12(:,iNoPhi);
K22 = K22(iNoPhi,iNoPhi);
%--------------------------------------------------------------------------
%---------------------- Global Matrix -------------------------------------
System.S = K11;
System.S = [System.S K12];
System.S = [System.S;K12.' K22];
% RHS
RHS = coilRHS + fixedRHS;
RHS = RHS(iEdA,1);
System.RHS = [RHS; zeros(length(iNoPhi),1)];

if any(diag(System.S)==0)
    error([mfilename ' : check the mesh and problem definition !']);
end

end


