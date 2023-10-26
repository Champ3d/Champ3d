function coefwn = f_cwn(c3dobj,varargin)
% F_CWN computes the mass matrix int_v(coef x Wn x dv)
%--------------------------------------------------------------------------
% OUTPUT
% coefwn : nb_elem x nbNo_inEl
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
arglist = {'design3d','id_design3d','dom_type','id_dom',...
           'phydomobj','coefficient'};

% --- default input value
design3d = [];
id_design3d = [];
dom_type  = [];
id_dom    = [];
phydomobj = [];
coefficient = [];

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
    [coef_array, coef_array_type] = f_tensor_array(coefficient);
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
nbNo_inEl = con.nbNo_inEl;
%--------------------------------------------------------------------------
for iG = 1:nbG
    Wn{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.Wn{iG}(id_elem,:);
    detJ{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwn = zeros(nb_elem,nbNo_inEl);
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    coef_array = f_tocolv(coef_array);
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbNo_inEl
            wni = Wn{iG}(:,i);
            coefwn(:,i) = coefwn(:,i) + weigh .* dJ .* coef_array .* wni;
        end
    end
    %----------------------------------------------------------------------
else
    error([mfilename ': #coefficient ' coefficient ' must be scalar !']);
end