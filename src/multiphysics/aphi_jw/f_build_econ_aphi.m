function design3d = f_build_econ_aphi(design3d,varargin)
% F_BUILD_ECON_APHI_JW returns the matrix system
% related to econductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_ECON_APHI_JW(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire
% University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);
%--------------------------------------------------------------------------
design3d.aphi.SWeWe = sparse(nbEdge,nbEdge);
%--------------------------------------------------------------------------
% TODO : loop for each mesh type
iNoPhi = [];
if isfield(design3d,'econductor')
    nb_dom = length(design3d.econductor);
    for i = 1:nb_dom
        %---------------------------------------------
        iNoPhi = [iNoPhi reshape(design3d.mesh.elem(1:con.nbNo_inEl,design3d.econductor(i).id_elem),...
                                 1,con.nbNo_inEl*length(design3d.econductor(i).id_elem))];
        %---------------------------------------------
        ltensor.main_value = f_calparam(design3d,design3d.econductor(i).sigma.main_value,'id_elem',design3d.econductor(i).id_elem);
        ltensor.ort1_value = f_calparam(design3d,design3d.econductor(i).sigma.ort1_value,'id_elem',design3d.econductor(i).id_elem);
        ltensor.ort2_value = f_calparam(design3d,design3d.econductor(i).sigma.ort2_value,'id_elem',design3d.econductor(i).id_elem);
        ltensor.main_dir = f_calparam(design3d,design3d.econductor(i).sigma.main_dir,'id_elem',design3d.econductor(i).id_elem);
        ltensor.ort1_dir = f_calparam(design3d,design3d.econductor(i).sigma.ort1_dir,'id_elem',design3d.econductor(i).id_elem);
        ltensor.ort2_dir = f_calparam(design3d,design3d.econductor(i).sigma.ort2_dir,'id_elem',design3d.econductor(i).id_elem);
        gtensor = f_gtensor(ltensor);
        design3d.econductor(i).gtensor = gtensor;
        design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                f_cwewe(design3d.mesh,'coef',design3d.econductor(i).gtensor,...
                  'id_elem',design3d.econductor(i).id_elem);

    end
    iNoPhi(iNoPhi == 0) = [];
    iNoPhi = unique(iNoPhi);
end
%--------------------------------------------------------------------------
design3d.aphi.id_node_phi = unique([design3d.aphi.id_node_phi iNoPhi]);
%--------------------------------------------------------------------------




