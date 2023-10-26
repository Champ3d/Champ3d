function coefwewf = f_cwewf(c3dobj,varargin)
% F_CWEWF computes the mass matrix int_v(coef x We x Wf x dv)
%--------------------------------------------------------------------------
% OUTPUT
% coefwewf : nb_elem x nbEd_inEl x nbFa_inEl
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
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
for iG = 1:nbG
    We{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.We{iG}(id_elem,:,:);
    Wf{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.Wf{iG}(id_elem,:,:);
    detJ{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwewf = zeros(nb_elem,nbEd_inEl,nbFa_inEl);
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbEd_inEl
            weix = We{iG}(:,1,i);
            weiy = We{iG}(:,2,i);
            weiz = We{iG}(:,3,i);
            for j = 1:nbFa_inEl % !!! 1
                wfjx = Wf{iG}(:,1,j);
                wfjy = Wf{iG}(:,2,j);
                wfjz = Wf{iG}(:,3,j);
                % ---
                coefwewf(:,i,j) = coefwewf(:,i,j) + ...
                    weigh .* dJ .* ( coef_array .* ...
                    (weix .* wfjx + weiy .* wfjy + weiz .* wfjz) );
            end
        end
    end
    %----------------------------------------------------------------------
elseif any(strcmpi(coef_array_type,{'tensor_array'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbEd_inEl
            weix = We{iG}(:,1,i);
            weiy = We{iG}(:,2,i);
            weiz = We{iG}(:,3,i);
            for j = 1:nbFa_inEl % !!! 1
                wfjx = Wf{iG}(:,1,j);
                wfjy = Wf{iG}(:,2,j);
                wfjz = Wf{iG}(:,3,j);
                % ---
                coefwewf(:,i,j) = coefwewf(:,i,j) + ...
                    weigh .* dJ .* (...
                    coef_array(:,1,1) .* weix .* wfjx +...
                    coef_array(:,1,2) .* weiy .* wfjx +...
                    coef_array(:,1,3) .* weiz .* wfjx +...
                    coef_array(:,2,1) .* weix .* wfjy +...
                    coef_array(:,2,2) .* weiy .* wfjy +...
                    coef_array(:,2,3) .* weiz .* wfjy +...
                    coef_array(:,3,1) .* weix .* wfjz +...
                    coef_array(:,3,2) .* weiy .* wfjz +...
                    coef_array(:,3,3) .* weiz .* wfjz );
            end
        end
    end
    %----------------------------------------------------------------------
end