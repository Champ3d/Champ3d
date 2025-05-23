%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTensor < Xhandle
    properties
        parent_model
        main_value
        main_dir
        ort1_value
        ort1_dir
        ort2_value
        ort2_dir
        rot_axis
        rot_angle
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model',...
                        'main_value','main_dir', ...
                        'ort1_value','ort1_dir', ....
                        'ort2_value','ort2_dir', ...
                        'rot_axis','rot_angle'};
        end
    end
    % --- Contructor
    methods
        function obj = LTensor(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,{'PhysicalModel','CplModel'})}
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
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model')
                error('#parent_model must be given !');
            end
            % ---
            obj <= args;
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function gtensor = getvalue(obj,args)
            arguments
                obj
                args.in_dom = [] %{mustBeA(args.in_dom,{'VolumeDom','SurfaceDom'})}
            end
            % ---
            dom = args.in_dom;
            if isa(dom,'PhysicalDom')
                meshdom = dom.dom;
            else
                meshdom = dom;
            end
            % ---
            if isa(meshdom,'VolumeDom')
                id_elem = meshdom.gindex;
            elseif isa(meshdom,'SurfaceDom')
                id_elem = meshdom.gindex;
            elseif isprop(meshdom,'gindex')
                id_elem = meshdom.gindex;
            elseif isprop(meshdom,'gindex')
                id_elem = meshdom.gindex;
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
                        if any(f_strcmpi(fn,{'main_dir','ort1_dir','ort2_dir','rot_axis'}))
                            ltfield = Array.vector(ltfield,'nb_elem',nb_elem);
                        else
                            ltfield = Array.tensor(ltfield,'nb_elem',nb_elem);
                        end
                        ltensor.(fn) = ltfield;
                    elseif isa(ltfield,'Parameter') || isa(ltfield,'LVector')
                        if isequal(obj.parent_model,ltfield.parent_model)
                            ltensor.(fn) = ltfield.getvalue('in_dom',dom);
                        else
                            error('#parent_model of LTensor obj must be the same as its parameters !');
                        end
                    end
                end
            end
            % --- normalize
            ltensor.main_dir = VectorArray.normalize(ltensor.main_dir);
            ltensor.ort1_dir = VectorArray.normalize(ltensor.ort1_dir);
            ltensor.ort2_dir = VectorArray.normalize(ltensor.ort2_dir);
            % ---
            if ~isempty(obj.rot_axis) && ~isempty(obj.rot_angle)
                for i = 1:nb_elem
                    % ---
                    raxis = ltensor.rot_axis(i,:) ./ norm(ltensor.rot_axis(i,:));
                    a = ltensor.rot_angle(i);
                    %------------------------------------------------------
                    ltensor.main_dir(i,:) = obj.rotaroundaxis(ltensor.main_dir(i,:),raxis,a);
                    ltensor.ort1_dir(i,:) = obj.rotaroundaxis(ltensor.ort1_dir(i,:),raxis,a);
                    ltensor.ort2_dir(i,:) = obj.rotaroundaxis(ltensor.ort2_dir(i,:),raxis,a);
                    %------------------------------------------------------
                end
            end
            % ---
            gtensor = obj.gtensor(ltensor);
            % ---
        end
        % -----------------------------------------------------------------
        function ginv = get_inverse(obj,args)
            arguments
                obj
                args.in_dom = [] %{mustBeA(args.in_dom,{'VolumeDom','SurfaceDom'})}
            end
            % ---
            dom = args.in_dom;
            % ---
            ginv = obj.getvalue('in_dom',dom);
            ginv = TensorArray.inverse(ginv);
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
        % -----------------------------------------------------------------
        function vrot = rotaroundaxis(obj,v,rot_axis,rot_angle)
            % ---
            if length(v) == 3
                dim = 3;
            else
                dim = 2;
            end
            % ---
            a = rot_angle / 180 * pi;
            if dim == 3
                ux = rot_axis(1); uy = rot_axis(2); uz = rot_axis(3);
                R  = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) - uz*sin(a)   ux*uz*(1-cos(a)) + uy*sin(a) ; ...
                      uy*ux*(1-cos(a)) + uz*sin(a)  cos(a) + uy^2 * (1-cos(a))     uy*uz*(1-cos(a)) - ux*sin(a) ;...
                      uz*ux*(1-cos(a)) - uy*sin(a)  uz*uy*(1-cos(a)) + ux*sin(a)   cos(a) + uz^2 * (1-cos(a))];
            elseif dim == 2
                ux = rot_axis_(1); uy = rot_axis_(2);
                R  = [cos(a) + ux^2 * (1-cos(a))    ux*uy*(1-cos(a)) ; ...
                      uy*ux*(1-cos(a))              cos(a) + uy^2 * (1-cos(a))];
            end
            % ---
            vrot = R * v.';
            vrot = vrot.';
        end
    end
end