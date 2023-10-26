function We = f_we(mesh3d,U,V,W,varargin)
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
arglist = {'wn','gradf','jinv'};

% --- default input value
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
if isfield(mesh3d,'ori_edge_in_elem')
    ori_edge_in_elem = mesh3d.ori_edge_in_elem;
else
    [~, ori_edge_in_elem, ~] = ...
        f_edgeinelem(elem,[],'elem_type',elem_type,'get','ori');
end
%--------------------------------------------------------------------------
if (numel(U) ~= numel(V)) || (numel(U) ~= numel(W))
    error([mfilename ': U, V, W do not have same size !']);
end
%--------------------------------------------------------------------------
if isempty(wn)
    wn = f_wn(mesh3d,U,V,W);
end
%--------------------------------------------------------------------------
if isempty(gradf)
    if isempty(jinv)
        [~, gradf] = f_gradwn(mesh3d,U,V,W,'get','gradF');
    else
        [~, gradf] = f_gradwn(mesh3d,U,V,W,'Jinv',jinv,'get','gradF');
    end
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbEd_inEl = con.nbEd_inEl;
EdNo_inEl = con.EdNo_inEl;
NoFa_ofEd = con.NoFa_ofEd;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
for i = 1:length(U)
    We{i} = zeros(nb_elem,3,nbEd_inEl);
end
%--------------------------------------------------------------------------
for i = 1:length(U)
    % ---
    fwe = zeros(nb_elem,3,nbEd_inEl);
    for j = 1:nbEd_inEl
        fwe(:,:,j) = - (wn{i}(:,EdNo_inEl(j,1)).*gradf{i}(:,:,NoFa_ofEd(j,1)) - ...
                        wn{i}(:,EdNo_inEl(j,2)).*gradf{i}(:,:,NoFa_ofEd(j,2)))...
                        .*ori_edge_in_elem(j,:).';
    end
    % ---
    We{i} = fwe;
end
%--------------------------------------------------------------------------