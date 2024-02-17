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
% CWFVF computes the mass matrix int_v(coef x Wf x Vf x dv)
arguments
    obj
    args.coefficient = 1
    args.vector_field = [1 1 1];
end

coefficient = args.coefficient;
vector_field = args.vector_field; % must be nb_elem x 3

%--------------------------------------------------------------------------
if isempty(coefficient)
    coef_array = 1;
    coef_array_type = 'iso_array';
else
    [coef_array, coef_array_type] = f_tensor_array(coefficient);
end
%--------------------------------------------------------------------------
elem_type = obj.elem_type;
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbG = con.nbG;
Weigh = con.Weigh;
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
Wf = cell(1,nbG);
detJ = cell(1,nbG);
for iG = 1:nbG
    Wf{iG} = obj.mesh3d.(id_mesh3d).intkit.Wf{iG}(id_elem,:,:);
    detJ{iG} = obj.mesh3d.(id_mesh3d).intkit.detJ{iG}(id_elem,1);
end
%--------------------------------------------------------------------------
coefwfvf = zeros(nb_elem,nbFa_inEl);
%--------------------------------------------------------------------------
if isempty(vector_field)
    vfx = 1;
    vfy = 1;
    vfz = 1;
else
    vfx = vector_field(:,1);
    vfy = vector_field(:,2);
    vfz = vector_field(:,3);
end
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
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* ( coef_array .* ...
                (wfix .* vfx + wfiy .* vfy + wfiz .* vfz) );
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
            coefwfvf(:,i) = coefwfvf(:,i) + ...
                weigh .* dJ .* (...
                coef_array(:,1,1) .* wfix .* vfx +...
                coef_array(:,1,2) .* wfiy .* vfx +...
                coef_array(:,1,3) .* wfiz .* vfx +...
                coef_array(:,2,1) .* wfix .* vfy +...
                coef_array(:,2,2) .* wfiy .* vfy +...
                coef_array(:,2,3) .* wfiz .* vfy +...
                coef_array(:,3,1) .* wfix .* vfz +...
                coef_array(:,3,2) .* wfiy .* vfz +...
                coef_array(:,3,3) .* wfiz .* vfz );
        end
    end
    %----------------------------------------------------------------------
end 