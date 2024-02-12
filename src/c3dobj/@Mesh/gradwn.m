%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function [gradWn, gradF] = gradwn(obj,varargin)

% --- valid argument list (to be updated each time modifying function)
arglist = {'u','v','w','jinv','get'};

% --- default input value
u = [];
v = [];
w = [];
jinv = [];
get = []; % 'gradF'

% --- default output value


% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
elem = obj.elem;
elem_type = obj.elem_type;
%--------------------------------------------------------------------------
if ~isempty(w)
    if (numel(u) ~= numel(v)) || (numel(u) ~= numel(w))
        error([mfilename ': u, v, w do not have same size !']);
    end
else
    if (numel(u) ~= numel(v))
        error([mfilename ': u, v do not have same size !']);
    end
end
%--------------------------------------------------------------------------
if isempty(jinv)
    [~, jinv] = obj.jacobien('u',u,'v',v,'w',w);
end
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    dim = 2;
    con = f_connexion(elem_type);
    nbNo_inEl = con.nbNo_inEl;
    FaNo_inEl = con.FaNo_inEl;
    nbFa_inEl = con.nbFa_inEl;
    fgradNx = con.gradNx;
    fgradNy = con.gradNy;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    lenu   = length(u);
    gradWn = cell(1,lenu);
    gradF  = cell(1,lenu);
    for i = 1:length(u)
        gradWn{i} = zeros(nb_elem,dim,nbNo_inEl);
        gradF{i}  = zeros(nb_elem,dim,nbFa_inEl);
    end
    %----------------------------------------------------------------------
    for i = 1:lenu
        u_ = u(i).*ones(1,nb_elem);
        v_ = v(i).*ones(1,nb_elem);
        % ---
        gradNx = fgradNx(u_,v_); gradNx = gradNx.';
        gradNy = fgradNy(u_,v_); gradNy = gradNy.';
        % ---
        fgradwn = zeros(nb_elem,dim,nbNo_inEl);
        Jinv1 = [jinv{i}(:,1,1), jinv{i}(:,1,2)];
        Jinv2 = [jinv{i}(:,2,1), jinv{i}(:,2,2)];
        for j = 1:nbNo_inEl
            gradNxy = [gradNx(:,j), gradNy(:,j)];
            fgradwn(:,1,j) = dot(Jinv1, gradNxy, 2);
            fgradwn(:,2,j) = dot(Jinv2, gradNxy, 2);
        end
        %------------------------------------------------------------------
        if any(strcmpi(get,{'gradF','sum_on_face'}))
            fgradf = zeros(nb_elem,dim,nbFa_inEl);
            for j = 1:nbFa_inEl
                nbN = length(find(FaNo_inEl(j,:)));
                fgradf(:,:,j) = sum(fgradwn(:,:,FaNo_inEl(j,1:nbN)),3);
            end
        end
        % ---
        gradWn{i} = fgradwn;
        gradF{i}  = fgradf;
    end
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    dim = 3;
    con = f_connexion(elem_type);
    nbNo_inEl = con.nbNo_inEl;
    FaNo_inEl = con.FaNo_inEl;
    nbFa_inEl = con.nbFa_inEl;
    fgradNx = con.gradNx;
    fgradNy = con.gradNy;
    fgradNz = con.gradNz;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    lenu   = length(u);
    gradWn = cell(1,lenu);
    gradF  = cell(1,lenu);
    for i = 1:length(u)
        gradWn{i} = zeros(nb_elem,dim,nbNo_inEl);
        gradF{i}  = zeros(nb_elem,dim,nbFa_inEl);
    end
    %----------------------------------------------------------------------
    for i = 1:lenu
        u_ = u(i).*ones(1,nb_elem);
        v_ = v(i).*ones(1,nb_elem);
        w_ = w(i).*ones(1,nb_elem);
        % ---
        gradNx = fgradNx(u_,v_,w_); gradNx = gradNx.';
        gradNy = fgradNy(u_,v_,w_); gradNy = gradNy.';
        gradNz = fgradNz(u_,v_,w_); gradNz = gradNz.';
        % ---
        fgradwn = zeros(nb_elem,dim,nbNo_inEl);
        Jinv1 = [jinv{i}(:,1,1), jinv{i}(:,1,2), jinv{i}(:,1,3)];
        Jinv2 = [jinv{i}(:,2,1), jinv{i}(:,2,2), jinv{i}(:,2,3)];
        Jinv3 = [jinv{i}(:,3,1), jinv{i}(:,3,2), jinv{i}(:,3,3)];
        for j = 1:nbNo_inEl
            gradNxyz = [gradNx(:,j), gradNy(:,j), gradNz(:,j)];
            fgradwn(:,1,j) = dot(Jinv1, gradNxyz, 2);
            fgradwn(:,2,j) = dot(Jinv2, gradNxyz, 2);
            fgradwn(:,3,j) = dot(Jinv3, gradNxyz, 2);
        end
        %------------------------------------------------------------------
        if any(strcmpi(get,{'gradF','sum_on_face'}))
            fgradf = zeros(nb_elem,dim,nbFa_inEl);
            for j = 1:nbFa_inEl
                nbN = length(find(FaNo_inEl(j,:)));
                fgradf(:,:,j) = sum(fgradwn(:,:,FaNo_inEl(j,1:nbN)),3);
            end
        end
        % ---
        gradWn{i} = fgradwn;
        gradF{i}  = fgradf;
    end
end