function Wn = f_wn(mesh3d,U,V,W,varargin)
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
if ~isfield(mesh3d,'elem')
    error([mfilename ' : #mesh3d struct must contain .elem']);
end
%--------------------------------------------------------------------------
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
fN = con.N;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
for i = 1:length(U)
    Wn{i} = zeros(nb_elem,nbNo_inEl);
end
%--------------------------------------------------------------------------
for i = 1:length(U)
    u = U(i).*ones(nb_elem,1);
    v = V(i).*ones(nb_elem,1);
    w = W(i).*ones(nb_elem,1);
    % ---
    fwn = zeros(nb_elem,nbNo_inEl);
    for j = 1:length(fN)
        fwn(:,j) = fN{j}(u,v,w);
    end
    % ---
    Wn{i} = fwn;
end
%--------------------------------------------------------------------------