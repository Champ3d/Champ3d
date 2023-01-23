function cfield = f_build_coil_type_2(mesh,coil,bcon)
% F_BUILD_COIL_T2 returns coil fields related to the source coil of type 2.
%   This is a J-source coil defined by :
%     + field_vector_o
%     + field_vector_v
%   in order to falicitate the impressed J-field
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
% coil : coil data structure
% bcon : boundary condition ID
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% cfield : coil field struct
%   cfield.cRHS : source term (RHS)
%   cfield.Js   : source current
%   cfield.N    : current turn density vector field
%--------------------------------------------------------------------------
% EXAMPLE
% cfield = F_BUILD_COIL_T2(mesh,coil,bcon);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of St-Nazaire, University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

IDElem = coil.id_elem;

%--------------------------------------------------------------------------
Alpha = zeros(mesh.nbNode,1);
IDNode_etrode = [];
for i = 1:length(coil.petrode)
    Alpha(coil.petrode(i).id_node) = 1;
    IDNode_etrode = [IDNode_etrode coil.petrode(i).id_node];
end
for i = 1:length(coil.netrode)
    Alpha(coil.netrode(i).id_node) = 0;
    IDNode_etrode = [IDNode_etrode coil.netrode(i).id_node];
end
IDNode_Alpha = setdiff(coil.id_node,IDNode_etrode);
%--------------------------------------------------------------------------
GradGrad = mesh.G.' * f_cwewe(mesh,'id_elem',IDElem) * mesh.G;
AlphRHS  = - GradGrad * Alpha;
GradGrad = GradGrad(IDNode_Alpha,IDNode_Alpha);
AlphRHS  = AlphRHS(IDNode_Alpha,1);
Alpha(IDNode_Alpha) = GradGrad \ AlphRHS;
%--------------------------------------------------------------------------
% figure
% IDElem = unique(mesh.face_in_elem(1:5,coil.id_elem));
% f_viewthings('type','face','node',mesh.node,'face',mesh.face(:,IDElem),...
%              'elem_type',mesh.elem_type,'node_field',Alph);
%--------------------------------------------------------------------------
Ecoil = mesh.G * Alpha;
vJs = zeros(3,mesh.nbElem); % Field direction
vJs(:,IDElem) = f_postpro3d(mesh,Ecoil,'W1','id_elem',IDElem);
vJs = f_normalize(vJs);     % Nomalized Field direction
%-----------------------Source field---------------------------------------
% current turn density vector field
cfield.N  = vJs .* (coil.nb_turn/coil.cs_area);
% current density vector field
Js = vJs .* coil.j_coil;
%--------------------------------------------------------------------------
MfJ = f_wfvf(mesh,'vector_field',Js);
F   = mesh.R.' * MfJ;
Mff = f_cwfwf(mesh);
S   = mesh.R.' * Mff * mesh.R;
%--------------------------------------------------------------------------
iEA = setdiff(1:mesh.nbEdge,bcon.id_edge);
F   = F(iEA,1);
S   = S(iEA,iEA);
%--------------------------------------------------------------------------
cRHS = zeros(mesh.nbEdge,1);
cRHS(iEA) = f_qmr(S,F);
%--------------------------------------------------------------------------
Mef = f_cwewf(mesh);
cfield.cRHS = mesh.R.' * Mef.' * cRHS;
%--------------------------------------------------------------------------
cfield.Js = Js;
%--------------------------------------------------------------------------
% rotT = mesh.R * cRHS;
% J = f_postpro(mesh,rotT,'W2');
% figure
% f_viewthings('type','elem','node',mesh.node,'elem',mesh.elem(:,IDElem),...
%              'elem_type',mesh.elem_type,'color','non')
% hold on
% quiver3(mesh.cnode(1,:),mesh.cnode(2,:),mesh.cnode(3,:),...
%         J(1,:),J(2,:),J(3,:),'color','m','AutoScaleFactor',2);
%--------------------------------------------------------------------------
% rotcRHS = mesh.R * cRHS;
% J = f_postpro(mesh,rotcRHS,'W2');
% figure
% f_viewthings('type','elem','node',mesh.node,'elem',mesh.elem(:,IDElem),...
%              'elem_type',mesh.elem_type,'color','non')
% hold on
% quiver3(mesh.cnode(1,:),mesh.cnode(2,:),mesh.cnode(3,:),...
%         J(1,:),J(2,:),J(3,:),'color','m','AutoScaleFactor',2);




