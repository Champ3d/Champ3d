function coefwewe = f_cwewe(c3dobj,varargin)
% F_CWEWE computes the mass matrix int_v(coef x We x We x dv)
%--------------------------------------------------------------------------
% OUTPUT
% coefwewe : nb_elem x nbEd_inEl x nbEd_inEl
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
arglist = {'design_type','id_design','dom_type','id_dom',...
           'phydomobj','coefficient',...
           'id_mesh3d','id_dom3d','id_elem'};

% --- default input value
design_type = [];
id_design = [];
dom_type  = [];
id_dom    = [];
phydomobj = [];
coefficient = [];
id_mesh3d = [];
id_dom3d = [];
id_elem = [];
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    if isempty(phydomobj)
        if ~isempty(design_type) && ~isempty(id_design) && ~isempty(dom_type) && ~isempty(id_dom)
            phydomobj = c3dobj.(design_type).(id_design).(dom_type).(id_dom);
        end
    end
    %--------------------------------------------------------------------------
    if isfield(phydomobj,'id_emdesign')
        id_mesh3d = c3dobj.emdesign.(phydomobj.id_emdesign).id_mesh3d;
    elseif isfield(phydomobj,'id_thdesign')
        id_mesh3d = c3dobj.thdesign3d.(phydomobj.id_thdesign).id_mesh3d;
    end
end
%--------------------------------------------------------------------------
if isempty(id_dom3d)
    if isfield(phydomobj,'id_dom3d')
        id_dom3d = phydomobj.id_dom3d;
    end
end
%--------------------------------------------------------------------------
if isempty(id_elem)
    id_elem = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
end
%--------------------------------------------------------------------------
nb_elem = length(id_elem);
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
%--------------------------------------------------------------------------
We = cell(1,nbG);
detJ = cell(1,nbG);
for iG = 1:nbG
    We{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.We{iG}(id_elem,:,:);
    detJ{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwewe = zeros(nb_elem,nbEd_inEl,nbEd_inEl);
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
            for j = i:nbEd_inEl % !!! i
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                wejz = We{iG}(:,3,j);
                % ---
                coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                    weigh .* dJ .* ( coef_array .* ...
                    (weix .* wejx + weiy .* wejy + weiz .* wejz) );
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
            for j = i:nbEd_inEl % !!! i
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                wejz = We{iG}(:,3,j);
                % ---
                coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                    weigh .* dJ .* (...
                    coef_array(:,1,1) .* weix .* wejx +...
                    coef_array(:,1,2) .* weiy .* wejx +...
                    coef_array(:,1,3) .* weiz .* wejx +...
                    coef_array(:,2,1) .* weix .* wejy +...
                    coef_array(:,2,2) .* weiy .* wejy +...
                    coef_array(:,2,3) .* weiz .* wejy +...
                    coef_array(:,3,1) .* weix .* wejz +...
                    coef_array(:,3,2) .* weiy .* wejz +...
                    coef_array(:,3,3) .* weiz .* wejz );
            end
        end
    end
    %----------------------------------------------------------------------
end

