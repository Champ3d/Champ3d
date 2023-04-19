function design3d = f_build_bcon_aphi(design3d,varargin)
% F_BUILD_BCON_APHI returns the matrix system
% related to mconductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_BCON_APHI(dom3D,option);
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

%---------------------- Boundary condition --------------------------------
iEdAfixed = [];
iNoPhi2Remove = [];
design3d.aphi.fixedRHS = zeros(nbEdge,1);
%-----
if isfield(design3d.aphi,'id_bcon_for_a')
    nb_bcon = length(design3d.aphi.id_bcon_for_a);
    for i = 1:nb_bcon
        id_bcon = design3d.aphi.id_bcon_for_a(i);
        switch lower(design3d.bcon(i).bc_type)
            case 'fixed'
                iEdAfixed = [iEdAfixed design3d.bcon(id_bcon).id_edge];
                % --- TODO : bc_value ~= 0
                %X = zeros(nbEdge,1);
                %if design3d.bcon(id_bcon).bc_value ~= 0
                    %X(design3d.bcon(id_bcon).id_edge) = design3d.bcon(id_bcon).bc_value;
                    %design3d.aphi.fixedRHS = design3d.aphi.fixedRHS + K11 * X;
                %end
                % ---------------------------------------------------------
            case 'xxx'
        end
    end
end
%-----
if isfield(design3d.aphi,'id_bcon_sibc')
    nb_bcon_sibc = length(design3d.aphi.id_bcon_sibc);
    for i = 1:nb_bcon_sibc
        id_bcon = design3d.aphi.id_bcon_sibc(i);
        %----- edge
        iEdinBCdom = reshape(design3d.mesh.edge_in_elem(1:con.nbEd_inEl,design3d.bcon(id_bcon).id_elem),...
                             1,con.nbEd_inEl*length(design3d.bcon(id_bcon).id_elem));
        iEdinBCdom = unique(iEdinBCdom);
        iEdinBCdom(iEdinBCdom == 0) = [];
        iEd2Remove = setdiff(iEdinBCdom,design3d.bcon(id_bcon).id_edge);
        iEdAfixed = [iEdAfixed iEd2Remove];
        %----- node
        iNoinBCdom = reshape(design3d.mesh.elem(1:con.nbNo_inEl,design3d.bcon(id_bcon).id_elem),...
                             1,con.nbNo_inEl*length(design3d.bcon(id_bcon).id_elem));
        iNoinBCdom = unique(iNoinBCdom);
        iNoinBCdom(iNoinBCdom == 0) = [];
        iNo2Remove = setdiff(iNoinBCdom,design3d.bcon(id_bcon).id_node);
        %iNoPhi = setdiff(iNoPhi,iNo2Remove);
        iNoPhi2Remove = [iNoPhi2Remove iNo2Remove];
        %----- face
        if isfield(design3d.bcon(id_bcon),'cparam')
            design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                         f_build_sibc(design3d.mesh,'id_face',design3d.bcon(id_bcon).id_face,...
                           'fr',design3d.aphi.fr,...
                           'gtsigma',design3d.bcon(id_bcon).gtsigma,...
                           'gtmur',design3d.bcon(id_bcon).gtmur,...
                           'cparam',design3d.bcon(id_bcon).cparam);
        else
            design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                         f_build_sibc(design3d.mesh,'id_face',design3d.bcon(id_bcon).id_face,...
                           'fr',design3d.aphi.fr,...
                           'gtsigma',design3d.bcon(id_bcon).gtsigma,...
                           'gtmur',design3d.bcon(id_bcon).gtmur);
        end
    end
end
%--------------------------------------------------------------------------
iNoPhi2Remove = unique(iNoPhi2Remove);
design3d.aphi.id_node_phi = unique(setdiff(design3d.aphi.id_node_phi, iNoPhi2Remove));
%--------------------------------------------------------------------------

% ---
% iEdA = setdiff(1:nbEdge,iEdAfixed);
% iEdA(iEdA == 0) = [];
% iEdA = unique(iEdA);
% design3d.aphi.id_edge_a = unique([design3d.aphi.id_edge_a iEdA]);
% ---

iEdAfixed = unique(iEdAfixed);
design3d.aphi.id_edge_a = unique(setdiff(design3d.aphi.id_edge_a,iEdAfixed));
%--------------------------------------------------------------------------

% figure
% edge = design3d.mesh.edge(1:2,iEdAfixed);
% node = design3d.mesh.node;
% for i = 1:length(iEdAfixed)
%     plot3([node(1,edge(1,i)) node(1,edge(2,i))],...
%           [node(2,edge(1,i)) node(2,edge(2,i))],...
%           [node(3,edge(1,i)) node(3,edge(2,i))],...
%           ['-b'],'lineWidth',1);
%     hold on
% end
% 
% figure
% f_viewthings('node',design3d.mesh.node,...
%              'edge',design3d.mesh.edge(1:2,iEdAfixed),...
%              'type','edge');


