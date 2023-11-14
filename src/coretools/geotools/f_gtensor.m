function gtensor = f_gtensor(ltensor)
% F_GTENSOR returns the tensors of physical property in global coordinates.
% o-- ltensor must be numeric
%--------------------------------------------------------------------------
% FIXED INPUT
% ltensor : array of local tensor structure in local coordinates.
%
% ltensor.main_value = 10; % main value
% ltensor.ort1_value = 1;  % first orthogonal value 
% ltensor.ort2_value = 1;  % second orthogonal value
%
% ltensor.main_dir = [1 +1 0]; % main direction
% ltensor.ort1_dir = [1 -1 0]; % first orthogonal direction 
% ltensor.ort2_dir = [0  0 1]; % second orthogonal direction 
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
% gtensor : [3 x 3 x nb_input_tensors] matrix of tensors in global coordinates.
%--------------------------------------------------------------------------
% EXAMPLE
%
% ltensor.main_value = 10;
% ltensor.ort1_value = 1;
% ltensor.ort2_value = 1;
%
% ltensor.main_dir = [1 +1 0];
% ltensor.ort1_dir = [1 -1 0];
% ltensor.ort2_dir = [0  0 1];
%
% gtensor = F_GTENSOR(ltensor);
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- default output value
if isfield(ltensor,'ort2_value')
    dim = 3;
    gtensor = zeros(length(ltensor.main_value),3,3);
else
    dim = 2;
    gtensor = zeros(length(ltensor.main_value),2,2);
end

if dim == 3
    for iten = 1:length(ltensor.main_value)
        %----------------------------------------------------------------------
        main_value = ltensor.main_value(iten);
        ort1_value = ltensor.ort1_value(iten);
        ort2_value = ltensor.ort2_value(iten);
        %----------------------------------------------------------------------
        main_dir = ltensor.main_dir(iten,:);
        ort1_dir = ltensor.ort1_dir(iten,:);
        ort2_dir = ltensor.ort2_dir(iten,:);
        %----------------------------------------------------------------------
        % local coordinates system
        tensor = [main_value 0           0; ...
                   0          ort1_value  0; ...
                   0          0           ort2_value];
        lix = [1 0 0];
        liy = [0 1 0];
        liz = [0 0 1];
        lcoor = [lix; liy; liz];
        %----------------------------------------------------------------------
        % global coordinates system
        gix = main_dir./norm(main_dir);
        giy = ort1_dir./norm(ort1_dir);
        giz = ort2_dir./norm(ort2_dir);
        gcoor = [gix; giy; giz];
        %----------------------------------------------------------------------
        % transformation matrix local --> global
        TM = zeros(3,3);
        for i = 1:3
            for j = 1:3
                TM(i,j) = dot(gcoor(i,:),lcoor(j,:));
            end
        end
        %----------------------------------------------------------------------
        gtensor(iten,:,:) = reshape(TM' * tensor * TM, 1, 3, 3);
        %----------------------------------------------------------------------
    end
elseif dim == 2
    for iten = 1:length(ltensor.main_value)
        %----------------------------------------------------------------------
        main_value = ltensor.main_value(iten);
        ort1_value = ltensor.ort1_value(iten);
        %----------------------------------------------------------------------
        main_dir = ltensor.main_dir(iten,:);
        ort1_dir = ltensor.ort1_dir(iten,:);
        %----------------------------------------------------------------------
        % local coordinates system
        tensor = [main_value 0 ; ...
                   0         ort1_value ];
        lix = [1 0];
        liy = [0 1];
        lcoor = [lix; liy];
        %----------------------------------------------------------------------
        % global coordinates system
        gix = main_dir./norm(main_dir);
        giy = ort1_dir./norm(ort1_dir);
        gcoor = [gix; giy];
        %----------------------------------------------------------------------
        % transformation matrix local --> global
        TM = zeros(2,2);
        for i = 1:2
            for j = 1:2
                TM(i,j) = dot(gcoor(i,:),lcoor(j,:));
            end
        end
        %----------------------------------------------------------------------
        gtensor(iten,:,:) = reshape(TM' * tensor * TM, 1, 2, 2);
        %----------------------------------------------------------------------
    end
end


