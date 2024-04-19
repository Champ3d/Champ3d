%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function [detJ, Jinv] = jacobien(obj,varargin)

% --- valid argument list (to be updated each time modifying function)
arglist = {'u','v','w'};

% --- default input value
u = [];
v = [];
w = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
node = obj.node;
elem = obj.elem;
flat_node = obj.flat_node;
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
refelem = obj.refelem;
nbNo_inEl = refelem.nbNo_inEl;
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    dim = 2;
    fgradNx = refelem.gradNx;
    fgradNy = refelem.gradNy;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    if isempty(flat_node)
        x = permute(reshape(node(1,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
        y = permute(reshape(node(2,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
    else
        if nb_elem == 1
            x = squeeze(flat_node(1,:,:));
            y = squeeze(flat_node(2,:,:));
        else
            x = permute(squeeze(flat_node(1,:,:)),[2 1]);
            y = permute(squeeze(flat_node(2,:,:)),[2 1]);
        end
    end
    %----------------------------------------------------------------------
    lenu = length(u);
    detJ = cell(1,lenu);
    Jinv = cell(1,lenu);
    for i = 1:length(u)
        detJ{i} = zeros(nb_elem,1);
        Jinv{i} = zeros(nb_elem,dim,dim);
    end
    %----------------------------------------------------------------------
    for i = 1:lenu
        u_ = u(i).*ones(1,nb_elem);
        v_ = v(i).*ones(1,nb_elem);
        %------------------------------------------------------------------
        gradNx = fgradNx(u_,v_); gradNx = gradNx.';
        gradNy = fgradNy(u_,v_); gradNy = gradNy.';
        % ---
        J11 = sum(gradNx.*x,2);
        J12 = sum(gradNx.*y,2);
        % ---
        J21 = sum(gradNy.*x,2);
        J22 = sum(gradNy.*y,2);
        % ---
        dJ = J11.*J22 - J21.*J12;
        % ---
        Ji = zeros(nb_elem,dim,dim);
        Ji(:,1,1) =  1./dJ.*J22;
        Ji(:,1,2) = -1./dJ.*J12;
        Ji(:,2,1) = -1./dJ.*J21;
        Ji(:,2,2) =  1./dJ.*J11;
        % ---
        detJ{i} = dJ;
        Jinv{i} = Ji;
    end
    %----------------------------------------------------------------------
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    dim = 3;
    fgradNx = refelem.gradNx;
    fgradNy = refelem.gradNy;
    fgradNz = refelem.gradNz;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    x = permute(reshape(node(1,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
    y = permute(reshape(node(2,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
    z = permute(reshape(node(3,elem(:,:)),nbNo_inEl,nb_elem),[2 1]);
    %----------------------------------------------------------------------
    lenu = length(u);
    detJ = cell(1,lenu);
    Jinv = cell(1,lenu);
    for i = 1:lenu
        detJ{i} = zeros(nb_elem,1);
        Jinv{i} = zeros(nb_elem,dim,dim);
    end
    %----------------------------------------------------------------------
    for i = 1:lenu
        u_ = u(i).*ones(1,nb_elem);
        v_ = v(i).*ones(1,nb_elem);
        w_ = w(i).*ones(1,nb_elem);
        %------------------------------------------------------------------
        gradNx = fgradNx(u_,v_,w_); gradNx = gradNx.';
        gradNy = fgradNy(u_,v_,w_); gradNy = gradNy.';
        gradNz = fgradNz(u_,v_,w_); gradNz = gradNz.';
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
        Ji = zeros(nb_elem,dim,dim);
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
    %----------------------------------------------------------------------
end