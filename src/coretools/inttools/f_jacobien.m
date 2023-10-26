function [detJ, Jinv] = f_jacobien(mesh3d,U,V,W,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if ~isfield(mesh3d,'node') || ~isfield(mesh3d,'elem')
    error([mfilename ' : #mesh3d struct must contain at least .node and .elem']);
end
%--------------------------------------------------------------------------
node = mesh3d.node;
elem = mesh3d.elem;
%--------------------------------------------------------------------------
if isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
else
    elem_type = f_elemtype(elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
if (numel(U) ~= numel(V)) || (numel(U) ~= numel(W))
    error([mfilename ': U, V, W do not have same size !']);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
fgradNx = con.gradNx;
fgradNy = con.gradNy;
fgradNz = con.gradNz;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
x = permute(reshape(node(1,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
y = permute(reshape(node(2,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
z = permute(reshape(node(3,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
%--------------------------------------------------------------------------
for i = 1:length(U)
    detJ{i} = zeros(nb_elem,1);
    Jinv{i} = zeros(nb_elem,3,3);
end
%--------------------------------------------------------------------------
for i = 1:length(U)
    u = U(i).*ones(1,nb_elem);
    v = V(i).*ones(1,nb_elem);
    w = W(i).*ones(1,nb_elem);
    %--------------------------------------------------------------------------
    gradNx = fgradNx(u,v,w); gradNx = gradNx.';
    gradNy = fgradNy(u,v,w); gradNy = gradNy.';
    gradNz = fgradNz(u,v,w); gradNz = gradNz.';
    % ---
    J11 = sum(gradNx.*x,2);
    J12 = sum(gradNx.*y,2);
    J13 = sum(gradNx.*z,2);
    % ---
    J21 = sum(gradNy.*x,2);
    J22 = sum(gradNy.*y,2);
    J23 = sum(gradNy.*z,2);
    % ---
    J31 = sum(gradNz.*x,2);
    J32 = sum(gradNz.*y,2);
    J33 = sum(gradNz.*z,2);
    % ---
    A11 = J22.*J33 - J23.*J32;
    A12 = J32.*J13 - J12.*J33;
    A13 = J12.*J23 - J13.*J22;
    A21 = J23.*J31 - J21.*J33;
    A22 = J33.*J11 - J31.*J13;
    A23 = J13.*J21 - J23.*J11;
    A31 = J21.*J32 - J31.*J22;
    A32 = J31.*J12 - J32.*J11;
    A33 = J11.*J22 - J12.*J21;
    % ---
    dJ = J11.*J22.*J33 + J21.*J32.*J13 + J31.*J12.*J23 - ...
         J11.*J32.*J23 - J31.*J22.*J13 - J21.*J12.*J33;
    % ---
    Ji = zeros(nb_elem,3,3);
    Ji(:,1,1) = 1./dJ.*A11;
    Ji(:,1,2) = 1./dJ.*A12;
    Ji(:,1,3) = 1./dJ.*A13;
    Ji(:,2,1) = 1./dJ.*A21;
    Ji(:,2,2) = 1./dJ.*A22;
    Ji(:,2,3) = 1./dJ.*A23;
    Ji(:,3,1) = 1./dJ.*A31;
    Ji(:,3,2) = 1./dJ.*A32;
    Ji(:,3,3) = 1./dJ.*A33;
    % ---
    detJ{i} = dJ;
    Jinv{i} = Ji;
end
%--------------------------------------------------------------------------