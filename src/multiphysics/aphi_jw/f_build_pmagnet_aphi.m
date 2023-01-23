function design3d = f_build_pmagnet_aphi(design3d,varargin)
% F_MAKEMAGNET returns the RHS matrix related to pmagnets (for a-phi-jw)
%--------------------------------------------------------------------------
% FIXED INPUT
% dom3d : 3D physics domain data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% dom3d : with pmagnetRHS added to dom3d.aphi
%--------------------------------------------------------------------------
% EXAMPLE
% dom3d = F_MAKEMAGNET(dom3d);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of St-Nazaire, University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

% for i = 1:(nargin-1)/2
%     eval([varargin{2*i-1} '= varargin{2*i};']);
% end

Br = zeros(3,design3d.mesh.nbElem); % Field direction

%---------------------- Source - RHS - PMagnet ----------------------------
% TODO : loop for each mesh type

design3d.aphi.pmagnetRHS = zeros(design3d.mesh.nbEdge,1);
if isfield(design3d,'pmagnet')
    nb_dom = length(design3d.pmagnet);
    for i = 1:nb_dom
        %SFace  = f_measure(dom3d.mesh.node,dom3d.mesh.face(:,dom3d.pmagnet(i).id_face),'face');
        %nFace  = f_chavec(dom3d.mesh.node,dom3d.mesh.face(:,dom3d.pmagnet(i).id_face),'face');
        %Br     = dom3d.pmagnet(i).br_value;
        %Flux   = SFace .* f_dot(nFace);

        IDElem = design3d.pmagnet(i).id_elem;
        nbElem = length(IDElem);
        %----------------------------------------------------------------------
        xCen = design3d.mesh.cnode(1,IDElem); 
        yCen = design3d.mesh.cnode(2,IDElem); 
        zCen = design3d.mesh.cnode(3,IDElem);
        br_ori = zeros(3,nbElem);
        for j = 1:nbElem
            br_ori(:,j) = design3d.pmagnet(i).br_ori(xCen(j),yCen(j),zCen(j));
        end
        br_ori = f_normalize(br_ori);
        Br(:,IDElem) = design3d.pmagnet(i).br_value .* br_ori;
    end
    %----------------------------------------------------------------------
    MfJ = f_wfvf(design3d.mesh,'vector_field',Br);
    F   = design3d.mesh.R.' * MfJ;
    Mff = f_cwfwf(design3d.mesh);
    S   = design3d.mesh.R.' * Mff * design3d.mesh.R;

    %--------------------------------------------------------------------------
    iEA = setdiff(1:design3d.mesh.nbEdge,design3d.bcon(design3d.pmagnet(i).id_bcon).id_edge);
    F   = F(iEA,1);
    S   = S(iEA,iEA);
    % figure
    % f_viewthings('type','edge','node',mesh.node,'edge',mesh.edge(:,bcon(ibcon).id_edge));
    %--------------------------------------------------------------------------
    ABr = zeros(design3d.mesh.nbEdge,1);
    ABr(iEA) = f_qmr(S,F);
    %--------------------------------------------------------------------------
    %rotA = dom3d.mesh.R * mRHS;
    %B = f_postpro3d(dom3d.mesh,rotA,'W2');
    %figure
    %f_viewthings('type','elem','node',dom3d.mesh.node,'elem',dom3d.mesh.elem(:,dom3d.pmagnet(1).id_elem),...
    %         'elem_type','prism','color','r'); hold on
    %f_quiver(dom3d.mesh.cnode,real(B),'sfactor',2);
    %--------------------------------------------------------------------------
    mu0 = 4*pi*1e-7;
    Mff = f_cwfwf(design3d.mesh,'coef',1/(mu0*design3d.pmagnet(i).mur));
    design3d.aphi.pmagnetRHS = design3d.aphi.pmagnetRHS + design3d.mesh.R.' * Mff * design3d.mesh.R * ABr;
end








