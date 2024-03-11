%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function vector_field = field_wf(obj,args)
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
if numel(dof) ~= obj.nb_face
    error('dof must be defined in whole mesh !');
end
%--------------------------------------------------------------------------
[coefficient, coef_array_type] = obj.column_format(coefficient);
dof = obj.column_format(dof);
%--------------------------------------------------------------------------
elem_type = obj.elem_type;
con = f_connexion(elem_type);
nbFa_inEl = con.nbFa_inEl;
%--------------------------------------------------------------------------
if isempty(obj.meshds.id_face_in_elem)
    obj.build_meshds;
end
id_face_in_elem = obj.meshds.id_face_in_elem;
%--------------------------------------------------------------------------
switch on_
    case 'center'
        % ---
        if isempty(obj.intkit.cWf)
            obj.build_intkit;
        end
        % ---
        nbG = 1;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
        end
    case 'gauss_points'
        % ---
        if isempty(obj.intkit.Wf)
            obj.build_intkit;
        end
        % ---
        nbG = con.nbG;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
        end
    case 'interpolation_points'
        % ---
        if isempty(obj.prokit.Wf)
            obj.build_prokit;
        end
        % ---
        nbG = obj.refelem.nbI;
        % ---
        Wx = cell(1,nbG);
        for iG = 1:nbG
            Wx{iG} = obj.prokit.Wf{iG}(id_elem,:,:);
        end
end
%--------------------------------------------------------------------------
for i = 1:nbG
    vector_field{i} = sparse(3,nb_elem);
end
%--------------------------------------------------------------------------
if any(f_strcmpi(coef_array_type,{'scalar'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        fi = zeros(length(id_elem),3);
        for i = 1:nbFa_inEl
            wix = Wx{iG}(:,1,i);
            wiy = Wx{iG}(:,2,i);
            wiz = Wx{iG}(:,3,i);
            id_face = id_face_in_elem(i,id_elem);
            fi(:,1) = fi(:,1) + coefficient .* wix .* dof(id_face);
            fi(:,2) = fi(:,2) + coefficient .* wiy .* dof(id_face);
            fi(:,3) = fi(:,3) + coefficient .* wiz .* dof(id_face);
        end
        % ---
        vector_field{iG}(1:3,id_elem) = fi.';
    end
    % ---
    if nbG == 1
        vector_field = vector_field{1};
    end
    %----------------------------------------------------------------------
elseif any(f_strcmpi(coef_array_type,{'tensor'}))
    %----------------------------------------------------------------------
    for iG = 1:nbG
        fi = zeros(3,length(id_elem));
        %------------------------------------------------------------------
        for i = 1:nbFa_inEl
            wix = Wx(:,1,i);
            wiy = Wx(:,2,i);
            wiz = Wx(:,3,i);
            id_face = id_face_in_elem(i,id_elem);
            fi(1,:) = fi(1,:) + (coefficient(:,1,1) .* wix + ...
                                 coefficient(:,1,2) .* wiy + ...
                                 coefficient(:,1,3) .* wiz) .* dof(id_face) ;
            fi(2,:) = fi(2,:) + (coefficient(:,2,1) .* wix + ...
                                 coefficient(:,2,2) .* wiy + ...
                                 coefficient(:,2,3) .* wiz) .* dof(id_face) ;
            fi(3,:) = fi(3,:) + (coefficient(:,3,1) .* wix + ...
                                 coefficient(:,3,2) .* wiy + ...
                                 coefficient(:,3,3) .* wiz) .* dof(id_face) ;
        end
        % ---
        vector_field{iG}(1:3,id_elem) = fi.';
    end
    % ---
    if nbG == 1
        vector_field = vector_field{1};
    end
    %----------------------------------------------------------------------
end