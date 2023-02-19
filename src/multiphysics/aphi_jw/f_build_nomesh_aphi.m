function design3d = f_build_nomesh_aphi(design3d,varargin)
% F_BUILD_NOMESH_APHI returns the matrix system
% related to nomesh for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_NOMESH_APHI(dom3D,option);
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

%---------------------- no mesh region ------------------------------------
iEd2Remove = [];
iNo2Remove = [];
id_elem_nomesh = [];
%-----
if isfield(design3d,'nomesh')
    nb_nomesh = length(design3d.nomesh);
    for i = 1:nb_nomesh
        %--- bound of no mesh region
        id_elem_nomesh = [id_elem_nomesh design3d.nomesh(i).id_elem];
        %--- bound of no mesh region
        bcmesh = f_make_mds(...
                    design3d.mesh.node,...
                    design3d.mesh.elem(:,design3d.nomesh(i).id_elem),...
                    design3d.mesh.elem_type);
        id_face = ...
            f_findvec(bcmesh.bound(1:max(con.nbNo_inFa),:),...
                      design3d.mesh.face(1:max(con.nbNo_inFa),:));
        edge_bound = unique(design3d.mesh.edge_in_face(1:max(con.nbEd_inFa{1}),id_face)); % !!!!
        node_bound = unique(design3d.mesh.face(1:max(con.nbNo_inFa(1)),id_face)); % !!!!
        %----- edge
        for j = 1:con.nbEd_inEl
            iEd2Remove = [iEd2Remove design3d.mesh.edge_in_elem(j,design3d.nomesh(i).id_elem)];
        end
        %----- node
        for j = 1:con.nbNo_inEl
            iNo2Remove = [iNo2Remove design3d.mesh.elem(j,design3d.nomesh(i).id_elem)];
        end
        %----- face
        %----- filter out bound
        iEd2Remove = setdiff(iEd2Remove,edge_bound);
        iNo2Remove = setdiff(iNo2Remove,node_bound);
    end
end
%--------------------------------------------------------------------------
iNo2Remove = unique(iNo2Remove);
design3d.aphi.id_node_phi = unique(setdiff(design3d.aphi.id_node_phi, iNo2Remove));
%--------------------------------------------------------------------------
iEd2Remove = unique(iEd2Remove);
design3d.aphi.id_edge_a = unique(setdiff(design3d.aphi.id_edge_a, iEd2Remove));
%--------------------------------------------------------------------------
id_elem_nomesh = unique(id_elem_nomesh);
design3d.aphi.id_elem_nomesh = unique([design3d.aphi.id_elem_nomesh id_elem_nomesh]);



