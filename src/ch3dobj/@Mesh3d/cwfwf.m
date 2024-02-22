%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function coefwfwf = cwfwf(obj,args)
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
nbFa_inEl = con.nbFa_inEl;
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
        Wf = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wf{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = con.nbG;
        Weigh = con.Weigh;
        % ---
        Wf = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wf{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
        end
end
%--------------------------------------------------------------------------
coefwfwf = zeros(nb_elem,nbFa_inEl,nbFa_inEl);
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wix = Wf{iG}(:,1,i);
            wiy = Wf{iG}(:,2,i);
            wiz = Wf{iG}(:,3,i);
            for j = i:nbFa_inEl % !!! i
                wjx = Wf{iG}(:,1,j);
                wjy = Wf{iG}(:,2,j);
                wjz = Wf{iG}(:,3,j);
                % ---
                coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                    weigh .* dJ .* ( coefficient .* ...
                    (wix .* wjx + wiy .* wjy + wiz .* wjz) );
            end
        end
    end
    %----------------------------------------------------------------------
elseif any(f_strcmpi(coef_array_type,{'tensor'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wix = Wf{iG}(:,1,i);
            wiy = Wf{iG}(:,2,i);
            wiz = Wf{iG}(:,3,i);
            for j = i:nbFa_inEl % !!! i
                wjx = Wf{iG}(:,1,j);
                wjy = Wf{iG}(:,2,j);
                wjz = Wf{iG}(:,3,j);
                % ---
                coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                    weigh .* dJ .* (...
                    coefficient(:,1,1) .* wix .* wjx +...
                    coefficient(:,1,2) .* wiy .* wjx +...
                    coefficient(:,1,3) .* wiz .* wjx +...
                    coefficient(:,2,1) .* wix .* wjy +...
                    coefficient(:,2,2) .* wiy .* wjy +...
                    coefficient(:,2,3) .* wiz .* wjy +...
                    coefficient(:,3,1) .* wix .* wjz +...
                    coefficient(:,3,2) .* wiy .* wjz +...
                    coefficient(:,3,3) .* wiz .* wjz );
            end
        end
    end
    %----------------------------------------------------------------------
end