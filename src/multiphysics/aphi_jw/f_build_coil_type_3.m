function cfield = f_build_coil_type_3(mesh,coil,varargin)
% F_MAKECOILT3 returns coil fields related to the source coil of type 3.
%--------------------------------------------------------------------------
% FIXED INPUT
% mesh : mesh data structure
% coil : coil data structure
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% cfield : coil field struct
%   cfield.N        : current turn density vector field
%   cfield.Alpha    : source voltage field
%   cfield.Js       : current density vector field
%--------------------------------------------------------------------------
% EXAMPLE
% cfield = F_MAKECOILT3(mesh,coil);
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
v_etrode = f_normalize(coil.v_etrode);
for i = 1:length(coil.etrode)
    Alpha(coil.etrode(i).id_node) = v_etrode(i);
    IDNode_etrode = [IDNode_etrode coil.etrode(i).id_node];
end
IDNode_Alpha = setdiff(coil.id_node,IDNode_etrode);

%--------------------------------------------------------------------------
GradGrad = mesh.G.' * f_coefWeWe(mesh,'id_elem',IDElem) * mesh.G;
AlphaRHS  = - GradGrad * Alpha;
GradGrad = GradGrad(IDNode_Alpha,IDNode_Alpha);
AlphaRHS  = AlphaRHS(IDNode_Alpha,1);
Alpha(IDNode_Alpha) = GradGrad \ AlphaRHS; % f_qmr(GradGrad,AlphRHS);
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

%--------------------------------------------------------------------------
% figure
% f_quiver(mesh.cnode,vJs,'sfactor',1);

%-----------------------Source field---------------------------------------
% current turn density vector field
cfield.N  = vJs .* coil.nb_turn/coil.cs_area;
% source voltage field
cfield.Alpha = Alpha;
% current density vector field
cfield.Js = vJs .* coil.j_coil;





