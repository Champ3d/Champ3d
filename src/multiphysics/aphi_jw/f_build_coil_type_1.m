function cfield = f_build_coil_type_1(mesh,coil,bcon)
% F_BUILD_COIL_T1 returns coil fields related to the source coil of type 1.
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
% cfield = F_BUILD_COIL_T1(mesh,coil,bcon);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of St-Nazaire, University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

IDElem = coil.id_elem;

%----------------------------------------------------------
xCen = mesh.cnode(1,IDElem); 
yCen = mesh.cnode(2,IDElem); 
zCen = mesh.cnode(3,IDElem);
%--------
fvlen = max([max(mesh.node(1,:))-min(mesh.node(1,:)); ...
             max(mesh.node(2,:))-min(mesh.node(2,:)); ...
             max(mesh.node(3,:))-min(mesh.node(3,:))]);
fvlen = 100 * fvlen; % try to create a "big" vector
xi = coil.field_vector_o(1) - coil.field_vector_v(1)*fvlen;
yi = coil.field_vector_o(2) - coil.field_vector_v(2)*fvlen;
zi = coil.field_vector_o(3) - coil.field_vector_v(3)*fvlen;
xf = xi + 2*fvlen*coil.field_vector_v(1);
yf = yi + 2*fvlen*coil.field_vector_v(2);
zf = zi + 2*fvlen*coil.field_vector_v(3);
%--------
lambda = ((xf-xi)*(xCen-xi) + (yf-yi)*(yCen-yi) + (zf-zi)*(zCen-zi))...
             ./((xf-xi)^2 + (yf-yi)^2 + (zf-zi)^2);
%--------
xp = xi + lambda*(xf-xi);   % Projected point
yp = yi + lambda*(yf-yi);
zp = zi + lambda*(zf-zi);
%--------
vJs = zeros(3,mesh.nbElem); % Field direction
vJs(1,IDElem) = (yf-yi)*(zCen-zp) - (yCen-yp)*(zf-zi); 
vJs(2,IDElem) = (zf-zi)*(xCen-xp) - (zCen-zp)*(xf-xi);
vJs(3,IDElem) = (xf-xi)*(yCen-yp) - (xCen-xp)*(yf-yi);
vJs = f_normalize(vJs);     % Nomalized Field direction
%-----------------------Source field---------------------------------------
% current turn density vector field
cfield.N  = vJs .* coil.nb_turn ./ coil.cs_area;
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
%         J(1,:),J(2,:),J(3,:),'color','m','AutoScaleFactor',2); axis equal; axis image
%--------------------------------------------------------------------------
% rotcRHS = mesh.R * cRHS;
% J = f_postpro(mesh,rotcRHS,'W2');
% figure
% f_viewthings('type','elem','node',mesh.node,'elem',mesh.elem(:,IDElem),...
%              'elem_type',mesh.elem_type,'color','non')
% hold on
% quiver3(mesh.cnode(1,:),mesh.cnode(2,:),mesh.cnode(3,:),...
%         J(1,:),J(2,:),J(3,:),'color','m','AutoScaleFactor',2); axis equal; axis image




