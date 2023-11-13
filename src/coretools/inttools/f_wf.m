function Wf = f_wf(mesh3d,varargin)
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
arglist = {'u','v','w','flat_node','wn','gradf','jinv'};

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
if ~isfield(mesh3d,'node') || ~isfield(mesh3d,'elem')
    error([mfilename ' : #mesh3d/2d struct must contain at least .node and .elem']);
end
%--------------------------------------------------------------------------
node = mesh3d.node;
elem = mesh3d.elem;
%--------------------------------------------------------------------------
if isempty(elem_type)
    if isfield(mesh,'elem_type')
        elem_type = mesh.elem_type;
    else
        elem_type = f_elemtype(mesh.elem,'defined_on','elem');
    end
end
%--------------------------------------------------------------------------
if isfield(mesh3d,'ori_face_in_elem')
    ori_face_in_elem = mesh3d.ori_face_in_elem;
else
    [~, ori_face_in_elem, ~] = ...
        f_faceinelem(elem,node,[],'elem_type',elem_type);
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
    wn = f_wn(mesh3d,'u',u,'v',v,'w',w);
end
%--------------------------------------------------------------------------
if isempty(gradf)
    if isempty(jinv)
        [~, gradf] = f_gradwn(mesh3d,'u',u,'v',v,'w',w,'get','gradF');
    else
        [~, gradf] = f_gradwn(mesh3d,'u',u,'v',v,'w',w,'Jinv',jinv,'get','gradF');
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
Wf = cell(1,length(u));
for i = 1:length(u)
    Wf{i} = zeros(nb_elem,3,nbFa_inEl);
end
%--------------------------------------------------------------------------
for i = 1:length(u)
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