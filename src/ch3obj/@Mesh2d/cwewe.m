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
[coefficient, coef_array_type] = obj.column_format(coefficient);
%--------------------------------------------------------------------------
refelem = obj.refelem;
nbEd_inEl = refelem.nbEd_inEl;
%--------------------------------------------------------------------------
if isempty(obj.intkit.We) || isempty(obj.intkit.cWe)
    obj.build_intkit;
end
%--------------------------------------------------------------------------
switch order
    case '0'
        nbG = 1;
        Weigh = refelem.cWeigh;
        % ---
        We = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            We{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = refelem.nbG;
        Weigh = refelem.Weigh;
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
            for j = i:nbEd_inEl % !!! i
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                % ---
                coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                    weigh .* dJ .* ( coefficient .* ...
                    (weix .* wejx + weiy .* wejy) );
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
            for j = i:nbEd_inEl % !!! i
                wejx = We{iG}(:,1,j);
                wejy = We{iG}(:,2,j);
                % ---
                coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                    weigh .* dJ .* (...
                    coefficient(:,1,1) .* weix .* wejx +...
                    coefficient(:,1,2) .* weiy .* wejx +...
                    coefficient(:,2,1) .* weix .* wejy +...
                    coefficient(:,2,2) .* weiy .* wejy );
            end
        end
    end
    %----------------------------------------------------------------------
end