function coefwfvf = f_cwfvf(c3dobj,varargin)
% F_CWFWF computes the mass matrix int_v(coef x Wf x Wf x dv)
%--------------------------------------------------------------------------
% OUTPUT
% coefwfwf : nb_elem x nbFa_inEl x nbFa_inEl
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_design3d','dom_type','id_dom',...
           'phydomobj','coefficient','vector_field'};

% --- default input value
design3d = [];
id_design3d = [];
dom_type  = [];
id_dom    = [];
phydomobj = [];
coefficient = [];
vector_field = []; % must be nb_elem x 3

% --- default output value
coef_array = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(phydomobj)
    if ~isempty(design3d) && ~isempty(id_design3d) && ~isempty(dom_type) && ~isempty(id_dom)
        phydomobj = c3dobj.(design3d).(id_design3d).(dom_type).(id_dom);
    else
        return;
    end
end
%--------------------------------------------------------------------------
if isfield(phydomobj,'id_emdesign3d')
    id_mesh3d = c3dobj.emdesign3d.(phydomobj.id_emdesign3d).id_mesh3d;
elseif isfield(phydomobj,'id_thdesign3d')
    id_mesh3d = c3dobj.thdesign3d.(phydomobj.id_thdesign3d).id_mesh3d;
end
%--------------------------------------------------------------------------
id_dom3d  = phydomobj.id_dom3d;
id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
nb_elem   = length(id_elem);
%--------------------------------------------------------------------------
if isempty(coefficient)
    coef_array = 1;
    coef_array_type = 'iso_array';
else
    [coef_array, coef_array_type] = ...
        f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                                 'coefficient',coefficient);
end
%--------------------------------------------------------------------------
if isfield(c3dobj.mesh3d.(id_mesh3d),'elem_type')
    elem_type = c3dobj.mesh3d.(id_mesh3d).elem_type;
else
    elem_type = f_elemtype(c3dobj.mesh3d.(id_mesh3d).elem,'defined_on','elem');
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbG = con.nbG;
Weigh = con.Weigh;
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
for iG = 1:nbG
    Wf{iG} = c3dobj.mesh3d.(id_mesh3d).Wf{iG}(id_elem,:,:);
    detJ{iG} = c3dobj.mesh3d.(id_mesh3d).detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwfvf = zeros(nb_elem,nbFa_inEl);
%--------------------------------------------------------------------------
if isempty(vector_field)
    return;
else
    vfx = vector_field(:,1);
    vfy = vector_field(:,2);
    vfz = vector_field(:,3);
end
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    coef_array = f_tocolv(coef_array);
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wfix = Wf{iG}(:,1,i);
            wfiy = Wf{iG}(:,2,i);
            wfiz = Wf{iG}(:,3,i);
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* ( coef_array .* ...
                (wfix .* vfx + wfiy .* vfy + wfiz .* vfz) );
        end
    end
    %----------------------------------------------------------------------
elseif any(strcmpi(coef_array_type,{'tensor_array'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wfix = Wf{iG}(:,1,i);
            wfiy = Wf{iG}(:,2,i);
            wfiz = Wf{iG}(:,3,i);
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* (...
                coef_array(:,1,1) .* wfix .* vfx +...
                coef_array(:,1,2) .* wfiy .* vfx +...
                coef_array(:,1,3) .* wfiz .* vfx +...
                coef_array(:,2,1) .* wfix .* vfy +...
                coef_array(:,2,2) .* wfiy .* vfy +...
                coef_array(:,2,3) .* wfiz .* vfy +...
                coef_array(:,3,1) .* wfix .* vfz +...
                coef_array(:,3,2) .* wfiy .* vfz +...
                coef_array(:,3,3) .* wfiz .* vfz );
        end
    end
    %----------------------------------------------------------------------
end