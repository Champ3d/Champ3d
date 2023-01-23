function System = f_build_v(dom3D,options)
% F_MAKEV returns the matrix system related to V formulation of electrocinetic.
%--------------------------------------------------------------------------
% System = F_MAKEV(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

nbEdge = dom3D.mesh.nbEdge;
nbFace = dom3D.mesh.nbFace;
con = f_connexion('elem_type',dom3D.mesh.elem_type);

%--------------------------------------------------------------------------

if isfield(dom3D,'econductor')
    nb_dom = length(dom3D.econductor);
    SWeWe  = sparse(nbEdge,nbEdge);
    iNoPhi = [];
    for i = 1:nb_dom
        %---------------------------------------------
        iNoPhi = [iNoPhi reshape(dom3D.mesh.elem(1:con.nbNo_inEl,dom3D.econductor(i).IDElem),...
                                 1,con.nbNo_inEl*length(dom3D.econductor(i).IDElem))];
        %---------------------------------------------
        cx = dom3D.econductor(i).sigma(1,1); % !!!!
        cy = dom3D.econductor(i).sigma(2,2);
        cz = dom3D.econductor(i).sigma(3,3);
        theta = dom3D.econductor(i).sigori;
        phi   = 90;
        sigma = zeros(3,3);
        sigma(1,1) = (cx*cos(theta)*sind(theta+phi) - cy*sind(theta)*cosd(theta+phi))/sind(phi);
        sigma(1,2) = (cy-cx)*cosd(theta)*cosd(theta+phi) / sind(phi);
        sigma(2,1) = (cx-cy)*sind(theta)*sind(theta+phi) / sind(phi);
        sigma(2,2) = (cy*cosd(theta)*sind(theta+phi)-cx*sind(theta)*cosd(theta+phi))/sind(phi);
        sigma(3,3) = cz;
        SWeWe = SWeWe + ...
                f_coefWeWe(mesh,'coef',sigma,...
                  'IDElem',dom3D.econductor(i).IDElem,'elem_type','prism');
    end
    iNoPhi(iNoPhi == 0) = [];
    iNoPhi = unique(iNoPhi);
    System.id_node_phi = iNoPhi;
end

if isfield(dom3D,'magnetic')
    nb_dom = length(dom3D.magnetic);
    SWfWf  = sparse(nbFace,nbFace);
    for i = 1:nb_dom
        cx = dom3D.magnetic(i).mur(1,1); % !!!!
        cy = dom3D.magnetic(i).mur(2,2);
        cz = dom3D.magnetic(i).mur(3,3);
        theta = dom3D.magnetic(i).murori;
        phi   = 90;
        mur = zeros(3,3);
        mur(1,1) = (cx*cos(theta)*sind(theta+phi) - cy*sind(theta)*cosd(theta+phi))/sind(phi);
        mur(1,2) = (cy-cx)*cosd(theta)*cosd(theta+phi) / sind(phi);
        mur(2,1) = (cx-cy)*sind(theta)*sind(theta+phi) / sind(phi);
        mur(2,2) = (cy*cosd(theta)*sind(theta+phi) - cx*sind(theta)*cosd(theta+phi))/sind(phi);
        mur(3,3) = cz;
        SWfWf = SWfWf + ...
                f_coefWeWe(mesh,'coef',mur,...
                  'IDElem',dom3D.magnetic(i).IDElem,'elem_type','prism');
    end
end

%--------------------------------------------------------------------------
%---------------------- Source - RHS --------------------------------------
if isfield(dom3D,'coil')
    nb_coil = length(dom3D.coil);
    for i = 1:nb_coil
        switch lower(dom3D.coil(i).coil_type)
            case 'stranded'
                switch dom3D.coil(1).defined_on
                    case 'elem'
                        f_makecoil(dom3D);
                    case 'xxx'
                end
            case 'massive'
            otherwise
        end
    end
end
%--------------------------------------------------------------------------
%---------------------- Boundary condition --------------------------------
K11 = dom3D.mesh.R.' * SWfWf * dom3D.mesh.R;
K11 = K11 + (1j*2*pi*dom3D.coil(1).fr) .* SWeWe;
K12 = (1j*2*pi*dom3D.coil(1).fr) .* (SWeWe * dom3D.mesh.G);
K22 = (1j*2*pi*dom3D.coil(1).fr) .* (dom3D.mesh.G.' * SWeWe * dom3D.mesh.G);

if isfield(options,'A_bcon')
    nb_bcon = length(options.A_bcon);
    iEdAfixed = [];
    for i = 1:nb_bcon
        switch lower(dom3D.bcon(i).bc_type)
            case 'fixed'
                iEdAfixed = [iEdAfixed dom3D.bcon(i).IDEdge];
                if dom3D.bcon(i).bc_value ~= 0
                    RHS = K11 * X;
                end
            case 'xxx'
        end
    end
    iEdA = setdiff(1:nbEdge,iEdAfixed);
    iEdA(iEdA == 0) = [];
    iEdA = unique(iEdA);
    System.id_edge_a = iEdA;
    % add to rhs
    
    % dirichlet remove
    K11 = K11(iEdA,iEdA);
    K12 = K12(iEdA,:);
    K12 = K12(:,iNoPhi);
    K22 = K22(iNoPhi,iNoPhi);
end

%--------------------------------------------------------------------------
%---------------------- Global Matrix -------------------------------------
System.S=K11;
System.S=[System.S K12];
System.S=[System.S;K12.' K22];

if any(diag(System.S)==0)
    disp('Error ! Check the mesh !')
    fclose('all');
end

end


