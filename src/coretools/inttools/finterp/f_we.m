function We = f_we(mesh,varargin)
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
arglist = {'u','v','w','flat_node','get','wn','gradf','jinv','elem_type'};

% --- default input value
u = [];
v = [];
w = [];
flat_node = [];
wn = [];
jinv = [];
gradf = [];
elem_type = [];

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
if ~isfield(mesh,'node') || ~isfield(mesh,'elem')
    error([mfilename ' : #mesh3d/2d struct must contain at least .node and .elem']);
end
%--------------------------------------------------------------------------
node = mesh.node;
elem = mesh.elem;
%--------------------------------------------------------------------------
if isempty(elem_type)
    if isfield(mesh,'elem_type')
        elem_type = mesh.elem_type;
    else
        elem_type = f_elemtype(mesh,'defined_on','elem');
    end
end
%--------------------------------------------------------------------------
if isfield(mesh,'ori_edge_in_elem')
    ori_edge_in_elem = mesh.ori_edge_in_elem;
else
    [~, ori_edge_in_elem, ~] = ...
        f_edgeinelem(elem,[],'elem_type',elem_type);
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
if isempty(wn)
    wn = f_wn(mesh,'u',u,'v',v,'w',w);
end
%--------------------------------------------------------------------------
if isempty(gradf)
    if isempty(jinv)
        [~, gradf] = f_gradwn(mesh,'u',u,'v',v,'w',w,'get','gradF');
    else
        [~, gradf] = f_gradwn(mesh,'u',u,'v',v,'w',w,'Jinv',jinv,'get','gradF');
    end
end
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    dim = 2;
    con = f_connexion(elem_type);
    nbEd_inEl = con.nbEd_inEl;
    EdNo_inEl = con.EdNo_inEl;
    NoFa_ofEd = con.NoFa_ofEd;
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
    con = f_connexion(elem_type);
    nbEd_inEl = con.nbEd_inEl;
    EdNo_inEl = con.EdNo_inEl;
    NoFa_ofEd = con.NoFa_ofEd;
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