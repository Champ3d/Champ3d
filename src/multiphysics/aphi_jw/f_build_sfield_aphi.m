function design3d = f_build_sfield_aphi(design3d,varargin)
% F_BUILD_SFIELD_APHI returns the r.h.s matrix related to Bs field.
%--------------------------------------------------------------------------
% design3d = F_BUILD_SFIELD_APHI(design3d, option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% for i = 1:(nargin-1)/2
%     eval([varargin{2*i-1} '= varargin{2*i};']);
% end

Bs = zeros(3,design3d.mesh.nbElem); % Field direction
%--------------------------------------------------------------------------
mRHS = zeros(design3d.mesh.nbEdge,1);

if isfield(design3d,'sfield')
    nb_sfield = length(design3d.sfield);
else
    nb_sfield = 0;
end

if nb_sfield ~= 0
    for i = 1:nb_sfield
        %SFace  = f_measure(dom3d.mesh.node,dom3d.mesh.face(:,dom3d.sfield(i).id_face),'face');
        %nFace  = f_chavec(dom3d.mesh.node,dom3d.mesh.face(:,dom3d.sfield(i).id_face),'face');
        %Br     = dom3d.sfield(i).br_value;
        %Flux   = SFace .* f_dot(nFace);

        IDElem = design3d.sfield(i).id_elem;
        nbElem = length(IDElem);
        %----------------------------------------------------------------------
        xCen = design3d.mesh.cnode(1,IDElem); 
        yCen = design3d.mesh.cnode(2,IDElem); 
        zCen = design3d.mesh.cnode(3,IDElem);
        Bs_ori = zeros(3,nbElem);
        Bs_val = zeros(1,nbElem);
        for j = 1:nbElem
            Bs_ori(:,j) = design3d.sfield(i).Bs_ori(xCen(j),yCen(j),zCen(j));
            Bs_val(:,j) = design3d.sfield(i).Bs_value(xCen(j),yCen(j),zCen(j));
        end
        Bs_ori = f_normalize(Bs_ori);
        %---
        Bs(1,IDElem) = Bs_val .* Bs_ori(1,:);
        Bs(2,IDElem) = Bs_val .* Bs_ori(2,:);
        Bs(3,IDElem) = Bs_val .* Bs_ori(3,:);
        %----------------------------------------------------------------------
        MfJ = f_WfVF(design3d.mesh,'vector_field',Bs);
        F   = design3d.mesh.R.' * MfJ;
        Mff = f_coefWfWf(design3d.mesh);
        S   = design3d.mesh.R.' * Mff * design3d.mesh.R;

        %--------------------------------------------------------------------------
        iEA = setdiff(1:design3d.mesh.nbEdge,design3d.bcon(design3d.sfield(i).id_bcon).id_edge);
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
        %f_viewthings('type','elem','node',dom3d.mesh.node,'elem',dom3d.mesh.elem(:,dom3d.sfield(1).id_elem),...
        %         'elem_type','prism','color','r'); hold on
        %f_quiver(dom3d.mesh.cnode,real(B),'sfactor',2);
        %--------------------------------------------------------------------------
        mu0 = 4*pi*1e-7;
        Mff = f_coefWfWf(design3d.mesh,'coef',1/(mu0*design3d.sfield(i).mur));
        mRHS = mRHS + design3d.mesh.R.' * Mff * design3d.mesh.R * ABr;
    end
end

design3d.aphi.sfieldRHS = mRHS;
design3d.aphi.Bs = Bs;

end








