%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function Wn = f_wn(obj,varargin)

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
refelem = obj.refelem;
nbNo_inEl = refelem.nbNo_inEl;
fN = refelem.N;
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