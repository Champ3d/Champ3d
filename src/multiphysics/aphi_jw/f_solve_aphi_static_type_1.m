function design3d = f_solve_aphi_static_type_1(design3d,varargin)
% F_BUILD_APHI_JW returns the matrix system related to A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_APHI_JW(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------


fprintf('Building aphi system ... \n');
%--------------------------------------------------------------------------
design3d.aphi.fr            = 0;
design3d.aphi.id_node_phi   = [];
design3d.aphi.id_edge_a     = [];
design3d.aphi.MVP           = [];
design3d.aphi.Phi           = [];
design3d.aphi.id_bcon_sibc  = [];
design3d.aphi.id_bcon_for_a = [];
linsolver_option.solver = [];
linsolver_option.tolerance = [];
linsolver_option.nb_iter = [];
newtonsolver_option.solver = [];
newtonsolver_option.tolerance = [];
newtonsolver_option.nb_iter = [];
newtonsolver_option.epsilon = [];
newtonsolver_option.iter_max = [];
%--------------------------------------------------------------------------
for i = 1:(nargin-1)/2
    design3d.aphi.(lower(varargin{2*i-1})) = varargin{2*i};
end
for i = 1:(nargin-1)/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i};']);
end
%--------------------------------------------------------------------------
if isempty(linsolver_option.solver)
    linsolver_option.solver = 'qmr';
end
if isempty(linsolver_option.tolerance)
    linsolver_option.tolerance = 1e-7;
end
if isempty(linsolver_option.nb_iter)
    linsolver_option.nb_iter = 1e4;
end
%--------------------------------------------------------------------------
if isempty(newtonsolver_option.solver)
    newtonsolver_option.solver = 'qmr';
end
if isempty(newtonsolver_option.tolerance)
    newtonsolver_option.tolerance = 1e-7;
end
if isempty(newtonsolver_option.nb_iter)
    newtonsolver_option.nb_iter = 1000;
end
if isempty(newtonsolver_option.epsilon)
    newtonsolver_option.epsilon = 1e-4;
end
if isempty(newtonsolver_option.iter_max)
    newtonsolver_option.iter_max = 50;
end
%--------------------------------------------------------------------------

nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);

%--------------------------------------------------------------------------
design3d = f_build_econ_aphi(design3d);
%--------------------------------------------------------------------------
design3d = f_build_mcon_aphi_type_1(design3d);
%--------------------------------------------------------------------------
design3d = f_build_air_aphi(design3d);
%--------------------------------------------------------------------------
design3d = f_build_pmagnet_aphi(design3d);
%--------------------------------------------------------------------------
design3d = f_build_coil_aphi(design3d);
%--------------------------------------------------------------------------
design3d = f_build_sfield_aphi(design3d);
%--------------------------------------------------------------------------
design3d = f_build_bcon_aphi(design3d);
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%---------------------------- Matrix system -------------------------------
%--------------------------- for static case ------------------------------
%--------------------------------------------------------------------------
S = design3d.mesh.R.' * ...
   (design3d.aphi.SWfnuWf + design3d.aphi.SWfWfAir) * ...
    design3d.mesh.R;
% --- dirichlet remove
S = S(design3d.aphi.id_edge_a,design3d.aphi.id_edge_a);
%---------------------- Global Matrix ---------------------------------
RHS = design3d.aphi.coilRHS + design3d.aphi.fixedRHS + design3d.aphi.pmagnetRHS + design3d.aphi.sfieldRHS;
RHS = RHS(design3d.aphi.id_edge_a,1);
if any(diag(S)==0)
    error([mfilename ' : zeros on the diagonal of system matrix --> check mesh and problem definition !']);
end
%--------------------------------------------------------------------------
if strcmpi(linsolver_option.solver, 'qmr')
    [MVPPhi,flag,relres,iter,resvec] = f_qmr(S,RHS,linsolver_option);
end
design3d.aphi.flag = flag;
design3d.aphi.relres = relres;
design3d.aphi.iter = iter;
design3d.aphi.resvec = resvec;
design3d.aphi.residual = resvec/norm(RHS);
%--------------------------------------------------------------------------
% --- Circulation of Magnetic Vector Potential (MVP)
design3d.aphi.MVP = zeros(design3d.mesh.nbEdge,1);
design3d.aphi.MVP(design3d.aphi.id_edge_a) = ...
        MVPPhi(1:length(design3d.aphi.id_edge_a));
% --- Phi
design3d.aphi.Phi = zeros(design3d.mesh.nbNode,1);
if length(MVPPhi) > length(design3d.aphi.id_edge_a)
    design3d.aphi.Phi(design3d.aphi.id_node_phi) = ...
        MVPPhi(length(design3d.aphi.id_edge_a)+1:...
               length(design3d.aphi.id_edge_a)+...
               length(design3d.aphi.id_node_phi));
end
%--------------------------------------------------------------------------
newton_flag = 0;
if isfield(design3d,'mconductor')
    nb_dom = length(design3d.mconductor);
    for idom = 1:nb_dom
        if strcmpi(design3d.mconductor(idom).mur.main_value.f,'bhdata')
            newton_flag = 1;
        end
    end
end
%---------------------- Newton-Raphson Iteration --------------------------
if newton_flag
    fprintf('Newton-Raphson solver ... \n');
    relerX = 1;
    iNew = 0;
    while ((relerX > newtonsolver_option.epsilon) & (iNew < newtonsolver_option.iter_max))
        % --- Newtion iteration number
        iNew = iNew + 1;
        design3d = f_build_mcon_aphi_type_1(design3d);
        S = design3d.mesh.R.' * ...
           (design3d.aphi.SWfnuWf + design3d.aphi.SWfWfAir) * ...
            design3d.mesh.R;
        % --- dirichlet remove
        S = S(design3d.aphi.id_edge_a,design3d.aphi.id_edge_a);
        % ---
        [MVPPhi] = f_qmr(S,RHS,linsolver_option);
        % --- update Residual
        R = S * MVPPhi - RHS;
        % --- update relative error
        relerR = norm(R)/norm(RHS);
        % --- dR/dA
        dR = design3d.mesh.R.' * ...
            (design3d.aphi.SWfnuWf + design3d.aphi.SWfdnudbWf + design3d.aphi.SWfWfAir)* ...
             design3d.mesh.R;
        dR = dR(design3d.aphi.id_edge_a,design3d.aphi.id_edge_a);
        % --- Solve delta MVP
        tic
        dMVP = f_qmr(dR,-R,newtonsolver_option);
        % --- relaxation coef
        if iNew == 1
            relax = 1;
        elseif relerR > relerR0
            relax = relax/2;
            if relax < 0.1
                relax = 0.1;
            end
        else
        end
        % --- update previous relative error
        relerR0 = relerR;
        % --- update MVP
        MVPPhi = MVPPhi + relax .* dMVP;
        % --- update relerror
        relerX = norm(dMVP)/norm(MVPPhi);
        % --- display
        fprintf('Newton iteration %d --- %.1f s --- |dR|/|b|=%.1fE-7, |dX|/|X|=%.1fE-7, relax=%.3f \n',...
                 iNew,toc,relerR*1e7,relerX*1e7,relax);
        % --- add solution of MVP
        design3d.aphi.MVP(design3d.aphi.id_edge_a) = ...
                 MVPPhi(1:length(design3d.aphi.id_edge_a));
        %------------------------------------------------------------------
    end
end

end

%--------------------------------------------------------------------------
%fprintf('%.4f s \n',toc);


