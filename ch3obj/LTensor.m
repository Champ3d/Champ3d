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
                id_elem = meshdom.gid_elem;
            elseif isa(meshdom,'SurfaceDom')
                id_elem = meshdom.gid_face;
            elseif isprop(meshdom,'gid_elem')
                id_elem = meshdom.gid_elem;
            elseif isprop(meshdom,'gid_face')
                id_elem = meshdom.gid_face;
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
                            ltfield = TensorArray.vector(ltfield,'nb_elem',nb_elem);
                        else
                            ltfield = TensorArray.scalar(ltfield,'nb_elem',nb_elem);
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
            ltensor.main_dir = f_normalize(ltensor.main_dir);
            ltensor.ort1_dir = f_normalize(ltensor.ort1_dir);
            ltensor.ort2_dir = f_normalize(ltensor.ort2_dir);
            % ---
            if ~isempty(obj.rot_axis) && ~isempty(obj.rot_angle)
                for i = 1:nb_elem
                    % ---
                    raxis = ltensor.rot_axis(:,i) ./ norm(ltensor.rot_axis(:,i));
                    a = ltensor.rot_angle(i);
                    %------------------------------------------------------
                    ltensor.main_dir(:,i) = obj.rotaroundaxis(ltensor.main_dir(:,i),raxis,a);
                    ltensor.ort1_dir(:,i) = obj.rotaroundaxis(ltensor.ort1_dir(:,i),raxis,a);
                    ltensor.ort2_dir(:,i) = obj.rotaroundaxis(ltensor.ort2_dir(:,i),raxis,a);
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
            ginv = [];
            gtensor  = obj.getvalue('in_dom',dom);
            sizeg = size(gtensor);
            lensg = length(sizeg); 
            if lensg == 3
                if sizeg(2) == sizeg(3)
                    if sizeg(2) == 2
                        % --- 
                        ginv = zeros(sizeg(1),2,2);
                        % ---
                        a11(1,:) = gtensor(:,1,1);
                        a12(1,:) = gtensor(:,1,2);
                        a21(1,:) = gtensor(:,2,1);
                        a22(1,:) = gtensor(:,2,2);
                        d = a11.*a22 - a21.*a12;
                        ix = find(d);
                        ginv(ix,1,1) = +1./d(ix).*a22(ix);
                        ginv(ix,1,2) = -1./d(ix).*a12(ix);
                        ginv(ix,2,1) = -1./d(ix).*a21(ix);
                        ginv(ix,2,2) = +1./d(ix).*a11(ix);
                    elseif sizeg(2) == 3
                        % --- 
                        ginv = zeros(sizeg(1),3,3);
                        % ---
                        a11(1,:) = gtensor(:,1,1);
                        a12(1,:) = gtensor(:,1,2);
                        a13(1,:) = gtensor(:,1,3);
                        a21(1,:) = gtensor(:,2,1);
                        a22(1,:) = gtensor(:,2,2);
                        a23(1,:) = gtensor(:,2,3);
                        a31(1,:) = gtensor(:,3,1);
                        a32(1,:) = gtensor(:,3,2);
                        a33(1,:) = gtensor(:,3,3);
                        A11 = a22.*a33 - a23.*a32;
                        A12 = a32.*a13 - a12.*a33;
                        A13 = a12.*a23 - a13.*a22;
                        A21 = a23.*a31 - a21.*a33;
                        A22 = a33.*a11 - a31.*a13;
                        A23 = a13.*a21 - a23.*a11;
                        A31 = a21.*a32 - a31.*a22;
                        A32 = a31.*a12 - a32.*a11;
                        A33 = a11.*a22 - a12.*a21;
                        d = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
                            a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;
                        ix = find(d);
                        ginv(ix,1,1) = 1./d(ix).*A11(ix);
                        ginv(ix,1,2) = 1./d(ix).*A12(ix);
                        ginv(ix,1,3) = 1./d(ix).*A13(ix);
                        ginv(ix,2,1) = 1./d(ix).*A21(ix);
                        ginv(ix,2,2) = 1./d(ix).*A22(ix);
                        ginv(ix,2,3) = 1./d(ix).*A23(ix);
                        ginv(ix,3,1) = 1./d(ix).*A31(ix);
                        ginv(ix,3,2) = 1./d(ix).*A32(ix);
                        ginv(ix,3,3) = 1./d(ix).*A33(ix);
                    else
                        f_fprintf(1,'Cannot inverse !',0,'\n');
                    end
                end
            else
                f_fprintf(1,'Cannot inverse !',0,'\n');
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
                    main_dir_ = ltensor.main_dir(:,iten);
                    ort1_dir_ = ltensor.ort1_dir(:,iten);
                    ort2_dir_ = ltensor.ort2_dir(:,iten);
                    %----------------------------------------------------------------------
                    % local coordinates system
                    tensor = [main_value_ 0           0; ...
                              0          ort1_value_  0; ...
                              0          0           ort2_value_];
                    lix = [1 0 0].';
                    liy = [0 1 0].';
                    liz = [0 0 1].';
                    lcoor = [lix liy liz];
                    %----------------------------------------------------------------------
                    % global coordinates system
                    gix = main_dir_./norm(main_dir_);
                    giy = ort1_dir_./norm(ort1_dir_);
                    giz = ort2_dir_./norm(ort2_dir_);
                    gcoor = [gix giy giz];
                    %----------------------------------------------------------------------
                    % transformation matrix local --> global
                    TM = zeros(3,3);
                    for i = 1:3
                        for j = 1:3
                            TM(i,j) = dot(gcoor(:,i),lcoor(:,j));
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
                    main_dir_ = ltensor.main_dir(:,iten);
                    ort1_dir_ = ltensor.ort1_dir(:,iten);
                    %----------------------------------------------------------------------
                    % local coordinates system
                    tensor = [main_value_ 0 ; ...
                              0         ort1_value_ ];
                    lix = [1 0].';
                    liy = [0 1].';
                    lcoor = [lix liy];
                    %----------------------------------------------------------------------
                    % global coordinates system
                    gix = main_dir_./norm(main_dir_);
                    giy = ort1_dir_./norm(ort1_dir_);
                    gcoor = [gix giy];
                    %----------------------------------------------------------------------
                    % transformation matrix local --> global
                    TM = zeros(2,2);
                    for i = 1:2
                        for j = 1:2
                            TM(i,j) = dot(gcoor(:,i),lcoor(:,j));
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
            vrot = R * v;
        end
    end
end