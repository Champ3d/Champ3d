function coefwewe = f_cwewe(c3dobj,varargin)
% F_CWEWE computes the mass matrix int_v(coef x We x We x dv)
%--------------------------------------------------------------------------
% OUTPUT
% CoefWeWe : nb_edges_in_volume x nb_edges_in_volume
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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
[coef_array, coef_array_type] = ...
    f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                             'coefficient',coefficient);
%--------------------------------------------------------------------------
id_mesh3d = phydomobj.id_mesh3d;
id_dom3d  = phydomobj.id_dom3d;
id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
nb_elem   = length(id_elem);
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
coefwewe = zeros(nb_elem,nbEd_inEl,nbEd_inEl);
%--------------------------------------------------------------------------

if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    coef_array = f_tocolv(coef_array);
    %----------------------------------------------------------------------
    for iG = 1:nbG
        for i = 1:nbEd_inEl
            for j = i:nbEd_inEl % !!! i
                weix = We{iG}(:,1,i);
                weiy = We{iG}(:,2,i);
                weiz = We{iG}(:,3,i);
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                wejz = We{iG}(:,3,j);
                dJ   = f_tocolv(detJ{iG});
                weigh= Weigh(iG);
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
        for i = 1:nbEd_inEl
            for j = i:nbEd_inEl % !!! i
                weix = We{iG}(:,1,i);
                weiy = We{iG}(:,2,i);
                weiz = We{iG}(:,3,i);
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                wejz = We{iG}(:,3,j);
                dJ   = f_tocolv(detJ{iG});
                weigh= Weigh(iG);
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



