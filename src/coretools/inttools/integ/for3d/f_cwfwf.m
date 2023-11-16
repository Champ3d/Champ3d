function coefwfwf = f_cwfwf(c3dobj,varargin)
% F_CWFWF computes the mass matrix int_v(coef x Wf x Wf x dv)
%--------------------------------------------------------------------------
% OUTPUT
% coefwfwf : nb_elem x nbFa_inEl x nbFa_inEl
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
arglist = {'design_type','id_design3d','dom_type','id_dom',...
           'phydomobj','coefficient'};

% --- default input value
design_type = [];
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
    if ~isempty(design_type) && ~isempty(id_design3d) && ~isempty(dom_type) && ~isempty(id_dom)
        phydomobj = c3dobj.(design_type).(id_design3d).(dom_type).(id_dom);
    else
        return;
    end
end
%--------------------------------------------------------------------------
if isfield(phydomobj,'id_emdesign')
    id_mesh3d = c3dobj.emdesign.(phydomobj.id_emdesign).id_mesh3d;
elseif isfield(phydomobj,'id_thdesign')
    id_mesh3d = c3dobj.thdesign.(phydomobj.id_thdesign).id_mesh3d;
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
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
Wf = cell(1,nbG);
detJ = cell(1,nbG);
for iG = 1:nbG
    Wf{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.Wf{iG}(id_elem,:,:);
    detJ{iG} = c3dobj.mesh3d.(id_mesh3d).intkit.detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwfwf = zeros(nb_elem,nbFa_inEl,nbFa_inEl);
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wfix = Wf{iG}(:,1,i);
            wfiy = Wf{iG}(:,2,i);
            wfiz = Wf{iG}(:,3,i);
            for j = i:nbFa_inEl % !!! i
                wfjx = Wf{iG}(:,1,j);
                wfjy = Wf{iG}(:,2,j);
                wfjz = Wf{iG}(:,3,j);
                % ---
                coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                    weigh .* dJ .* ( coef_array .* ...
                    (wfix .* wfjx + wfiy .* wfjy + wfiz .* wfjz) );
            end
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
            for j = i:nbFa_inEl % !!! i
                wfjx = Wf{iG}(:,1,j);
                wfjy = Wf{iG}(:,2,j);
                wfjz = Wf{iG}(:,3,j);
                % ---
                coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                    weigh .* dJ .* (...
                    coef_array(:,1,1) .* wfix .* wfjx +...
                    coef_array(:,1,2) .* wfiy .* wfjx +...
                    coef_array(:,1,3) .* wfiz .* wfjx +...
                    coef_array(:,2,1) .* wfix .* wfjy +...
                    coef_array(:,2,2) .* wfiy .* wfjy +...
                    coef_array(:,2,3) .* wfiz .* wfjy +...
                    coef_array(:,3,1) .* wfix .* wfjz +...
                    coef_array(:,3,2) .* wfiy .* wfjz +...
                    coef_array(:,3,3) .* wfiz .* wfjz );
            end
        end
    end
    %----------------------------------------------------------------------
end

