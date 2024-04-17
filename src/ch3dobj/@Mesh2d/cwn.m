%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function coefwn = cwn(obj,args)
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
nbNo_inEl = refelem.nbNo_inEl;
%--------------------------------------------------------------------------
if isempty(obj.intkit.Wn) || isempty(obj.intkit.cWn)
    obj.build_intkit;
end
%--------------------------------------------------------------------------
switch order
    case '0'
        nbG = 1;
        Weigh = refelem.cWeigh;
        % ---
        Wn = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wn{iG} = obj.intkit.cWn{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = refelem.nbG;
        Weigh = refelem.Weigh;
        % ---
        Wn = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wn{iG} = obj.intkit.Wn{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
        end
end
%--------------------------------------------------------------------------
coefwn = zeros(nb_elem,nbNo_inEl);
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbNo_inEl
            wix = Wn{iG}(:,i);
            coefwn(:,i) = coefwn(:,i) + ...
                weigh .* dJ .* coefficient .* wix;
        end
    end
    %----------------------------------------------------------------------
end