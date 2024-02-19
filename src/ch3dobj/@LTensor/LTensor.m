%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTensor < Xhandle
    properties
        main_value
        main_dir
        ort1_value
        ort1_dir
        ort2_value
        ort2_dir
        rot_axis
        rot_angle
    end

    % --- Contructor
    methods
        function obj = LTensor(args)
            arguments
                args.main_value = []
                args.main_dir = []
                args.ort1_value = []
                args.ort1_dir = []
                args.ort2_value = []
                args.ort2_dir = []
                args.rot_axis = []
                args.rot_angle = []
            end
            % ---
            % if ~isempty(args.rot_angle)
            %     if ~isnumeric(args.rot_angle)
            %         error('#rot_angle must be numeric');
            %     end
            % end
            % % ---
            % if ~isempty(args.rot_axis)
            %     if ~isnumeric(args.rot_axis)
            %         error('#rot_axis must be numeric');
            %     end
            % end
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        function gtensor = evaluate_on(obj,dom)
            % ---
            if isa(dom,'VolumeDom')
                id_elem = dom.gid_elem;
            elseif isa(dom,'SurfaceDom')
                id_elem = dom.gid_face;
            elseif isprop(dom,'gid_elem')
                id_elem = dom.gid_elem;
            elseif isprop(dom,'gid_face')
                id_elem = dom.gid_face;
            end
            % ---
            nb_elem = length(id_elem);
            % ---
            fnames = {'main_value','main_dir','ort1_value','ort1_dir',...
                      'ort2_value','ort2_dir','rot_axis','rot_angle'};
            % ---
            ltensor = [];
            for i = 1:length(fnames)
                fn = fnames{i};
                ltfield = obj.(fn);
                if ~isempty(ltfield)
                    if isnumeric(ltfield)
                        ltensor.(fn) = repmat(ltfield,nb_elem,1);
                    elseif isa(ltfield,'Parameter')
                        ltensor.(fn) = ltfield.evaluate_on(dom);
                    end
                end
            end
            % ---
            if ~isempty(ltensor.ort2_value)
                dim = 3;
                gtensor = zeros(nb_elem,3,3);
            else
                dim = 2;
                gtensor = zeros(nb_elem,2,2);
            end
            % ---
            if ~isempty(obj.rot_axis) && ~isempty(obj.rot_angle)
                for i = 1:nb_elem
                    lt.main_value = ltensor.main_value(i,:);
                    lt.main_dir = ltensor.main_dir(i,:,:);
                    lt.ort1_value = ltensor.ort1_value(i,:);
                    lt.ort1_dir = ltensor.ort1_dir(i,:,:);
                    if dim == 3
                        lt.ort2_value = ltensor.ort2_value(i,:);
                        lt.ort2_dir = ltensor.ort2_dir(i,:,:);
                    end
                    % ---
                    gtensor(i,:,:) = obj.gtensor(lt);
                end
            else
                % ---
                gtensor = f_gtensor(ltensor);
                % ---
            end
        end
        % -----------------------------------------------------------------
        function gtensor = gtensor(obj,ltensor)
            % ---
            if isfield(ltensor,'ort2_value')
                dim = 3;
                gtensor = zeros(length(ltensor.main_value),3,3);
            else
                dim = 2;
                gtensor = zeros(length(ltensor.main_value),2,2);
            end
            % ---
            if dim == 3
                for iten = 1:length(ltensor.main_value)
                    %----------------------------------------------------------------------
                    main_value_ = ltensor.main_value(iten);
                    ort1_value_ = ltensor.ort1_value(iten);
                    ort2_value_ = ltensor.ort2_value(iten);
                    %----------------------------------------------------------------------
                    main_dir_ = ltensor.main_dir(iten,:);
                    ort1_dir_ = ltensor.ort1_dir(iten,:);
                    ort2_dir_ = ltensor.ort2_dir(iten,:);
                    %----------------------------------------------------------------------
                    % local coordinates system
                    tensor = [main_value_ 0           0; ...
                              0          ort1_value_  0; ...
                              0          0           ort2_value_];
                    lix = [1 0 0];
                    liy = [0 1 0];
                    liz = [0 0 1];
                    lcoor = [lix; liy; liz];
                    %----------------------------------------------------------------------
                    % global coordinates system
                    gix = main_dir_./norm(main_dir_);
                    giy = ort1_dir_./norm(ort1_dir_);
                    giz = ort2_dir_./norm(ort2_dir_);
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
                    main_value_ = ltensor.main_value(iten);
                    ort1_value_ = ltensor.ort1_value(iten);
                    %----------------------------------------------------------------------
                    main_dir_ = ltensor.main_dir(iten,:);
                    ort1_dir_ = ltensor.ort1_dir(iten,:);
                    %----------------------------------------------------------------------
                    % local coordinates system
                    tensor = [main_value_ 0 ; ...
                              0         ort1_value_ ];
                    lix = [1 0];
                    liy = [0 1];
                    lcoor = [lix; liy];
                    %----------------------------------------------------------------------
                    % global coordinates system
                    gix = main_dir_./norm(main_dir_);
                    giy = ort1_dir_./norm(ort1_dir_);
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
        end
    end
end