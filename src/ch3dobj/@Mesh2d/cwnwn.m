%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function coefwnwn = cwnwn(obj,args)
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
elem_type = obj.elem_type;
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
%--------------------------------------------------------------------------
if isempty(obj.intkit.Wn) || isempty(obj.intkit.cWn)
    obj.build_intkit;
end
%--------------------------------------------------------------------------
switch order
    case '0'
        nbG = 1;
        Weigh = con.cWeigh;
        % ---
        Wn = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wn{iG} = obj.intkit.cWn{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = con.nbG;
        Weigh = con.Weigh;
        % ---
        Wn = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wn{iG} = obj.intkit.Wn{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
        end
end
%--------------------------------------------------------------------------
coefwnwn = zeros(nb_elem,nbNo_inEl,nbNo_inEl);
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbNo_inEl
            wix = Wn{iG}(:,i);
            for j = i:nbNo_inEl
                wjx = Wn{iG}(:,j);
                coefwnwn(:,i,j) = coefwnwn(:,i,j) + ...
                    weigh .* dJ .* coefficient .* wix .* wjx;
            end
        end
    end
    %----------------------------------------------------------------------
end