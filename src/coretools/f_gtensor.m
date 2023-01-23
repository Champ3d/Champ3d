function gtensor = f_gtensor(ltensor)
% F_GTENSOR returns the tensors of physical property in global coordinates.
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
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- default output value
gtensor = zeros(3,3,length(ltensor.main_value));

for iten = 1:length(ltensor.main_value)

    main_value = ltensor.main_value(iten);
    ort1_value = ltensor.ort1_value(iten);
    ort2_value = ltensor.ort2_value(iten);

    main_dir = ltensor.main_dir(iten,:);
    ort1_dir = ltensor.ort1_dir(iten,:);
    ort2_dir = ltensor.ort2_dir(iten,:);

    %--------------------------------------------------------------------------
    % local coordinates system
    tensor = [main_value 0           0; ...
               0          ort1_value  0; ...
               0          0           ort2_value];

    lix = main_dir./norm(main_dir);
    liy = ort1_dir./norm(ort1_dir);
    liz = ort2_dir./norm(ort2_dir);
    lcoor = [lix; liy; liz];

    %--------------------------------------------------------------------------
    % global coordinates system
    gix = [1 0 0];
    giy = [0 1 0];
    giz = [0 0 1];
    gcoor = [gix; giy; giz];

    %--------------------------------------------------------------------------
    % transformation matrix local --> global
    TM = zeros(3,3);
    for i = 1:3
        for j = 1:3
            TM(i,j) = dot(gcoor(i,:),lcoor(j,:));
        end
    end

    gtensor(:,:,iten) = TM' * tensor * TM;

end

% if length(ltensor.main_value) == 1
%     gtensor(:,:) = TM' * ltensor * TM;
% else
%     gtensor(:,:,iten) = TM' * ltensor * TM;
% end

