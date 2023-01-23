function design3d = f_build_air_aphi(design3d,varargin)
% F_BUILD_AIR_APHI returns the matrix system
% related to mconductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_AIR_APHI(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire
% University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);
%--------------------------------------------------------------------------
% TODO : loop for each mesh type
design3d.aphi.SWfWfAir = sparse(nbFace,nbFace);
mu0 = 4*pi*1e-7;
id_elem_mc = [];
if isfield(design3d,'mconductor')
    nb_dom = length(design3d.mconductor);
    for idom = 1:nb_dom
        %------------------------------------------------------------------
        id_elem_mc = [id_elem_mc design3d.mconductor(idom).id_elem];
        %------------------------------------------------------------------
    end
end
id_elem_mc = unique(id_elem_mc);
%--------------------------------------------------------------------------
id_elem_nm = [];
if isfield(design3d,'nomesh')
    nb_dom = length(design3d.nomesh);
    for idom = 1:nb_dom
        id_elem_nm = [id_elem_nm design3d.nomesh(idom).id_elem];
    end
end
%--------------------------------------------------------------------------
id_elem_vacumm = setdiff(1:nbElem,[id_elem_mc id_elem_nm]);
design3d.aphi.SWfWfAir = design3d.aphi.SWfWfAir + ...
        f_cwfwf(design3d.mesh,'coef',1/mu0,...
          'id_elem',id_elem_vacumm);


