%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function coefwfvf = cwfvf(obj,args)
arguments
    obj
    args.id_elem = []
    args.coefficient = 1
    args.vector_field = [1 1 1];
    args.order = 'full'
end
%--------------------------------------------------------------------------
id_elem = args.id_elem;
coefficient = args.coefficient;
order = args.order;
vector_field = args.vector_field;
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
vector_field = obj.column_format(vector_field);
%--------------------------------------------------------------------------
refelem = obj.refelem;
nbFa_inEl = refelem.nbFa_inEl;
%--------------------------------------------------------------------------
if isempty(obj.intkit.Wf) || isempty(obj.intkit.cWf)
    obj.build_intkit;
end
%--------------------------------------------------------------------------
switch order
    case '0'
        nbG = 1;
        Weigh = refelem.cWeigh;
        % ---
        Wf = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wf{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
        end
    case 'full'
        nbG = refelem.nbG;
        Weigh = refelem.Weigh;
        % ---
        Wf = cell(1,nbG);
        detJ = cell(1,nbG);
        for iG = 1:nbG
            Wf{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
            detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
        end
end
%--------------------------------------------------------------------------
coefwfvf = zeros(nb_elem,nbFa_inEl);
%--------------------------------------------------------------------------
if numel(vector_field) == 2
    vfx = vector_field(1);
    vfy = vector_field(2);
elseif size(vector_field,1) >  length(id_elem) && ...
       size(vector_field,1) == obj.nb_elem
    vfx = vector_field(id_elem,1);
    vfy = vector_field(id_elem,2);
else
    vfx = vector_field(:,1);
    vfy = vector_field(:,2);
end
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wfix = Wf{iG}(:,1,i);
            wfiy = Wf{iG}(:,2,i);
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* ( coefficient .* ...
                (wfix .* vfx + wfiy .* vfy) );
        end
    end
    %----------------------------------------------------------------------
elseif any(strcmpi(coef_array_type,{'tensor'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        dJ    = f_tocolv(detJ{iG});
        weigh = Weigh(iG);
        for i = 1:nbFa_inEl
            wfix = Wf{iG}(:,1,i);
            wfiy = Wf{iG}(:,2,i);
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* (...
                coefficient(:,1,1) .* wfix .* vfx +...
                coefficient(:,1,2) .* wfiy .* vfx +...
                coefficient(:,2,1) .* wfix .* vfy +...
                coefficient(:,2,2) .* wfiy .* vfy );
        end
    end
    %----------------------------------------------------------------------
end 