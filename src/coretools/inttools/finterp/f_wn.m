function Wn = f_wn(mesh,varargin)
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
arglist = {'u','v','w','flat_node','get'};

% --- default input value
u = [];
v = [];
w = [];
get = '_all';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if ~isfield(mesh,'elem')
    error([mfilename ' : #mesh3d/2d struct must contain .elem']);
end
%--------------------------------------------------------------------------
elem = mesh.elem;
%--------------------------------------------------------------------------
if isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
else
    error([mfilename ' : #mesh struct must contain .elem_type']);
end
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
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
fN = con.N;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
Wn = cell(1,length(u));
for i = 1:length(u)
    Wn{i} = zeros(nb_elem,nbNo_inEl);
end
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    for i = 1:length(u)
        u_ = u(i).*ones(nb_elem,1);
        v_ = v(i).*ones(nb_elem,1);
        % ---
        fwn = zeros(nb_elem,nbNo_inEl);
        for j = 1:length(fN)
            fwn(:,j) = fN{j}(u_,v_);
        end
        % ---
        Wn{i} = fwn;
    end
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    for i = 1:length(u)
        u_ = u(i).*ones(nb_elem,1);
        v_ = v(i).*ones(nb_elem,1);
        w_ = w(i).*ones(nb_elem,1);
        % ---
        fwn = zeros(nb_elem,nbNo_inEl);
        for j = 1:length(fN)
            fwn(:,j) = fN{j}(u_,v_,w_);
        end
        % ---
        Wn{i} = fwn;
    end
end
%--------------------------------------------------------------------------