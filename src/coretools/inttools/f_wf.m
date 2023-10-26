function Wf = f_wf(mesh3d,U,V,W,varargin)
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
if isfield(mesh3d,'ori_face_in_elem')
    ori_face_in_elem = mesh3d.ori_face_in_elem;
else
    [~, ori_face_in_elem, ~] = ...
        f_faceinelem(elem,node,[],'elem_type',elem_type,'get','ori');
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
nbFa_inEl = con.nbFa_inEl;
nbNo_inFa = con.nbNo_inFa;
FaNo_inEl = con.FaNo_inEl;
NoFa_ofFa = con.NoFa_ofFa;
%--------------------------------------------------------------------------
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
for i = 1:length(U)
    Wf{i} = zeros(nb_elem,3,nbFa_inEl);
end
%--------------------------------------------------------------------------
for i = 1:length(U)
    %----------------------------------------------------------------------
    nbNodemax = max(nbNo_inFa);
    for j = 1:nbNodemax
        gradFxgradF{j} = zeros(nb_elem,3,nbFa_inEl);
    end
    for j = 1:nbFa_inEl
        for k = 1:nbNo_inFa(j)
            knext = mod(k + 1,nbNo_inFa(j));
            if knext == 0
                knext = nbNo_inFa(j);
            end
            %-----
            gradFk = gradf{i}(:,:,NoFa_ofFa(j,k));
            gradFknext = gradf{i}(:,:,NoFa_ofFa(j,knext));
            %-----
            gradFxgradF{k}(:,:,j) = cross(gradFk,gradFknext,2);
        end
    end
    %----------------------------------------------------------------------
    fwf = zeros(nb_elem,3,nbFa_inEl);
    for j = 1:nbFa_inEl
        Wfxyz = zeros(nb_elem,3);
        for k = 1:nbNo_inFa(j)
            Wfxyz = Wfxyz + ...
                    wn{i}(:,FaNo_inEl(j,k)).*gradFxgradF{k}(:,:,j);
        end
        fwf(:,:,j) = (5 - nbNo_inFa(j)) .* Wfxyz .* ori_face_in_elem(j,:).';
    end
    % ---
    Wf{i} = fwf;
end
%--------------------------------------------------------------------------