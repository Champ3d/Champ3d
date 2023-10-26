function [gradWn, gradF] = f_gradwn(mesh3d,U,V,W,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'jinv','get'};

% --- default input value
jinv = [];
get = []; % 'gradF'

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
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
if isempty(jinv)
    [~, jinv] = f_jacobien(mesh3d,U,V,W,'elem_type',elem_type);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
FaNo_inEl = con.FaNo_inEl;
nbFa_inEl = con.nbFa_inEl;
fgradNx = con.gradNx;
fgradNy = con.gradNy;
fgradNz = con.gradNz;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
for i = 1:length(U)
    gradWn{i} = zeros(nb_elem,3,nbNo_inEl);
    gradF{i}  = zeros(nb_elem,3,nbFa_inEl);
end
%--------------------------------------------------------------------------
for i = 1:length(U)
    u = U(i).*ones(1,nb_elem);
    v = V(i).*ones(1,nb_elem);
    w = W(i).*ones(1,nb_elem);
    % ---
    gradNx = fgradNx(u,v,w); gradNx = gradNx.';
    gradNy = fgradNy(u,v,w); gradNy = gradNy.';
    gradNz = fgradNz(u,v,w); gradNz = gradNz.';
    % ---
    fgradwn = zeros(nb_elem,3,nbNo_inEl);
    Jinv1 = [jinv{i}(:,1,1), jinv{i}(:,1,2), jinv{i}(:,1,3)];
    Jinv2 = [jinv{i}(:,2,1), jinv{i}(:,2,2), jinv{i}(:,2,3)];
    Jinv3 = [jinv{i}(:,3,1), jinv{i}(:,3,2), jinv{i}(:,3,3)];
    for j = 1:nbNo_inEl
        gradNxyz = [gradNx(:,j), gradNy(:,j), gradNz(:,j)];
        fgradwn(:,1,j) = dot(Jinv1, gradNxyz, 2);
        fgradwn(:,2,j) = dot(Jinv2, gradNxyz, 2);
        fgradwn(:,3,j) = dot(Jinv3, gradNxyz, 2);
    end
    %----------------------------------------------------------------------
    if any(strcmpi(get,{'gradF','sum_on_face'}))
        fgradf = zeros(nb_elem,3,nbFa_inEl); % 3 for x,y,z
        for j = 1:nbFa_inEl
            nbN = length(find(FaNo_inEl(j,:)));
            fgradf(:,:,j) = sum(fgradwn(:,:,FaNo_inEl(j,1:nbN)),3);
        end
    end
    % ---
    gradWn{i} = fgradwn;
    gradF{i}  = fgradf;
end
