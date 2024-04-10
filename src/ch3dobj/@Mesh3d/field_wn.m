%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function scalar_field = field_wn(obj,args)
arguments
    obj
    args.id_elem = []
    args.coefficient = 1
    args.dof = 1
    args.on {mustBeMember(args.on,{'center','gauss_points','interpolation_points'})} = 'center'
end
%--------------------------------------------------------------------------
id_elem = args.id_elem;
coefficient = args.coefficient;
dof = args.dof;
on_ = args.on;
%--------------------------------------------------------------------------
nb_elem = obj.nb_elem;
% ---
if isempty(id_elem)
    id_elem = 1:nb_elem;
end
%--------------------------------------------------------------------------
if numel(dof) ~= obj.nb_node
    error('dof must be defined in whole mesh !');
end
%--------------------------------------------------------------------------
[coefficient, coef_array_type] = obj.column_format(coefficient);
dof = obj.column_format(dof);
%--------------------------------------------------------------------------
elem_type = obj.elem_type;
con = f_connexion(elem_type);
nbNo_inEl = con.nbNo_inEl;
%--------------------------------------------------------------------------
if isempty(obj.elem)
    error('No mesh data !');
end
elem = obj.elem;
%--------------------------------------------------------------------------
switch on_
    case 'center'
        % ---
        if isempty(obj.intkit.cWn)
            obj.build_intkit;
        end
        % ---
        nbG = 1;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.intkit.cWn{iG}(id_elem,:);
        end
    case 'gauss_points'
        % ---
        if isempty(obj.intkit.Wn)
            obj.build_intkit;
        end
        % ---
        nbG = con.nbG;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.intkit.Wn{iG}(id_elem,:);
        end
    case 'interpolation_points'
        % ---
        if isempty(obj.prokit.Wn)
            obj.build_prokit;
        end
        % ---
        nbG = obj.refelem.nbI;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.prokit.Wn{iG}(id_elem,:);
        end
end
%--------------------------------------------------------------------------
for i = 1:nbG
    scalar_field{i} = sparse(1,nb_elem);
end
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        fi = zeros(length(id_elem),1);
        for i = 1:nbNo_inEl
            wi = Wx{iG}(:,i);
            id_node = elem(i,id_elem);
            fi(:,1) = fi(:,1) + coefficient .* wi .* dof(id_node);
        end
        % ---
        scalar_field{iG}(1,id_elem) = fi.';
    end
    % ---
    if nbG == 1
        scalar_field = scalar_field{1};
    end
    %----------------------------------------------------------------------
end