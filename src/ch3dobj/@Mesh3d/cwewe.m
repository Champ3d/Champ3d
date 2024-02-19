%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function coefwewe = cwewe(obj,args)
arguments
    obj
    args.id_elem = []
    args.coefficient = 1
    args.order = 'full'
end
%--------------------------------------------------------------------------
id_elem = args.id_elem;
coefficient = args.coefficient;
order = args.order;
%--------------------------------------------------------------------------
if isempty(id_elem)
    nb_elem = obj.nb_elem;
    id_elem = 1:nb_elem;
else
    nb_elem = length(id_elem);
end
% ---
if isnumeric(order)
    if order < 1
        order = '0';
    else
        order = 'full';
    end
end
%--------------------------------------------------------------------------
[coef_array, coef_array_type] = obj.column_format(coefficient);
%--------------------------------------------------------------------------
elem_type = obj.elem_type;
con = f_connexion(elem_type);
nbEd_inEl = con.nbEd_inEl;
%--------------------------------------------------------------------------
if isempty(obj.intkit.Wf) || isempty(obj.intkit.cWf)
    obj.build_intkit;
end
%--------------------------------------------------------------------------
switch order
    case '0'
        nbG = 1;
        Weigh = con.cWeigh;
        % ---
        We = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            We{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = con.nbG;
        Weigh = con.Weigh;
        % ---
        We = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            We{iG} = obj.intkit.We{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
        end
end
%--------------------------------------------------------------------------
coefwewe = zeros(nb_elem,nbEd_inEl,nbEd_inEl);
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
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
elseif any(f_strcmpi(coef_array_type,{'tensor'}))
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