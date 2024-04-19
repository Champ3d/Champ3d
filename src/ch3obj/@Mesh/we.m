%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function We = we(obj,varargin)

% --- valid argument list (to be updated each time modifying function)
arglist = {'u','v','w','get','wn','gradf','jinv'};

% --- default input value
u = [];
v = [];
w = [];
wn = [];
jinv = [];
gradf = [];

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
ori_edge_in_elem = obj.meshds.ori_edge_in_elem;
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
if isempty(wn)
    wn = obj.wn('u',u,'v',v,'w',w);
end
%--------------------------------------------------------------------------
if isempty(gradf)
    if isempty(jinv)
        [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'get','gradF');
    else
        [~, gradf] = obj.gradwn('u',u,'v',v,'w',w,'Jinv',jinv,'get','gradF');
    end
end
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    dim = 2;
    refelem = obj.refelem;
    nbEd_inEl = refelem.nbEd_inEl;
    EdNo_inEl = refelem.EdNo_inEl;
    NoFa_ofEd = refelem.NoFa_ofEd;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    We = cell(1,length(u));
    for i = 1:length(u)
        We{i} = zeros(nb_elem,dim,nbEd_inEl);
    end
    %----------------------------------------------------------------------
    for i = 1:length(u)
        % ---
        fwe = zeros(nb_elem,dim,nbEd_inEl);
        for j = 1:nbEd_inEl
            fwe(:,:,j) = - (wn{i}(:,EdNo_inEl(j,1)).*gradf{i}(:,:,NoFa_ofEd(j,1)) - ...
                            wn{i}(:,EdNo_inEl(j,2)).*gradf{i}(:,:,NoFa_ofEd(j,2)))...
                            .*ori_edge_in_elem(j,:).';
        end
        % ---
        We{i} = fwe;
    end
    %----------------------------------------------------------------------
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    dim = 3;
    refelem = obj.refelem;
    nbEd_inEl = refelem.nbEd_inEl;
    EdNo_inEl = refelem.EdNo_inEl;
    NoFa_ofEd = refelem.NoFa_ofEd;
    %----------------------------------------------------------------------
    nb_elem = size(elem,2);
    %----------------------------------------------------------------------
    We = cell(1,length(u));
    for i = 1:length(u)
        We{i} = zeros(nb_elem,dim,nbEd_inEl);
    end
    %----------------------------------------------------------------------
    for i = 1:length(u)
        % ---
        fwe = zeros(nb_elem,dim,nbEd_inEl);
        for j = 1:nbEd_inEl
            fwe(:,:,j) = - (wn{i}(:,EdNo_inEl(j,1)).*gradf{i}(:,:,NoFa_ofEd(j,1)) - ...
                            wn{i}(:,EdNo_inEl(j,2)).*gradf{i}(:,:,NoFa_ofEd(j,2)))...
                            .*ori_edge_in_elem(j,:).';
        end
        % ---
        We{i} = fwe;
    end
    %----------------------------------------------------------------------
end