%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Parameter < Xhandle
    properties
        parent_model
        f
        depend_on
        from
        varargin_list
        fvectorized
        % ---
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','f','depend_on','from','varargin_list','fvectorized'};
        end
    end
    % --- Contructor
    methods
        function obj = Parameter(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,{'PhysicalModel','CplModel'})}
                args.f = []
                args.depend_on {mustBeMember(args.depend_on,...
                    {'celem','cface','velem','sface','ledge',...
                     'J','V','T','B','E','H','A','P','Phi',...
                     'ltime'})}
                args.from = []
                args.varargin_list = []
                args.fvectorized = 0
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model')
                error('#parent_model must be given !');
            end
            % ---
            if isempty(args.f)
                error('#f must be given ! Give a function handle or numeric value');
            end
            % ---
            if ~isfield(args,'depend_on')
                args.depend_on = '';
            end
            % ---
            if isnumeric(args.f)
                constant_parameter = args.f;
                args.f = @()(constant_parameter);
            elseif isa(args.f,'function_handle')
                if isempty(args.from)
                    error('#from must be given ! Give EMModel, THModel, ... ');
                else
                    args.from = f_to_scellargin(args.from);
                end
            else
                error('#f must be function handle or numeric value');
            end
            % ---
            obj.parent_model = args.parent_model;
            obj.f = args.f;
            obj.depend_on = f_to_scellargin(args.depend_on);
            obj.from = f_to_scellargin(args.from);
            obj.varargin_list = f_to_scellargin(args.varargin_list);
            obj.fvectorized = args.fvectorized;
            % --- check
            nb_fargin = f_nargin(obj.f);
            if nb_fargin > 0
                if nb_fargin ~= length(obj.depend_on)
                    error('Number of input arguments of #f must corresponds to #depend_on');
                elseif nb_fargin ~= length(obj.from)
                    error('Number of input arguments of #f must corresponds to #from');
                elseif length(obj.depend_on) ~= length(obj.from)
                    error('Number of elements in #depend_on must corresponds to #from');
                end
            end
            % -------------------------------------------------------------
        end
    end

    % --- Methods
    methods
        %------------------------------------------------------------------
        function vout = getvalue(obj,args)
            arguments
                obj
                args.in_dom = []
            end
            % ---
            dom = args.in_dom;
            % ---
            if obj.fvectorized
                vout = obj.eval_fvectorized(dom);
                vout = f_column_format(vout);
            else
                vout = obj.eval_fserial(dom);
                vout = f_column_format(vout);
            end
        end
        %------------------------------------------------------------------
        function vout = get_inverse(obj,args)
            arguments
                obj
                args.in_dom = []
                args.parameter_type {mustBeMember(args.parameter_type,{'auto','vector'})} = 'vector'
            end
            % ---
            dom = args.in_dom;
            parameter_type = args.parameter_type;
            % ---
            vout = [];
            vin  = obj.getvalue('in_dom',dom);
            sizev = size(vin);
            lensv = length(sizev);
            % ---
            if lensv == 2
                if sizev(2) == 1
                    if any(sizev(1) == [1 2 3])
                        if f_strcmpi(parameter_type,'vector')
                            vout = - vin;
                        else
                            vout = 1./vin;
                        end
                    else
                        vout = 1./vin;
                    end
                else
                    vout = - vin;
                end
            elseif lensv == 3
                if sizev(2) == sizev(3)
                    if sizev(2) == 2
                        % --- 
                        vout = zeros(sizev(1),2,2);
                        % ---
                        a11(1,:) = vin(:,1,1);
                        a12(1,:) = vin(:,1,2);
                        a21(1,:) = vin(:,2,1);
                        a22(1,:) = vin(:,2,2);
                        d = a11.*a22 - a21.*a12;
                        ix = find(d);
                        vout(ix,1,1) = +1./d(ix).*a22(ix);
                        vout(ix,1,2) = -1./d(ix).*a12(ix);
                        vout(ix,2,1) = -1./d(ix).*a21(ix);
                        vout(ix,2,2) = +1./d(ix).*a11(ix);
                    elseif sizev(2) == 3
                        % --- 
                        vout = zeros(sizev(1),3,3);
                        % ---
                        a11(1,:) = vin(:,1,1);
                        a12(1,:) = vin(:,1,2);
                        a13(1,:) = vin(:,1,3);
                        a21(1,:) = vin(:,2,1);
                        a22(1,:) = vin(:,2,2);
                        a23(1,:) = vin(:,2,3);
                        a31(1,:) = vin(:,3,1);
                        a32(1,:) = vin(:,3,2);
                        a33(1,:) = vin(:,3,3);
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
                        vout(ix,1,1) = 1./d(ix).*A11(ix);
                        vout(ix,1,2) = 1./d(ix).*A12(ix);
                        vout(ix,1,3) = 1./d(ix).*A13(ix);
                        vout(ix,2,1) = 1./d(ix).*A21(ix);
                        vout(ix,2,2) = 1./d(ix).*A22(ix);
                        vout(ix,2,3) = 1./d(ix).*A23(ix);
                        vout(ix,3,1) = 1./d(ix).*A31(ix);
                        vout(ix,3,2) = 1./d(ix).*A32(ix);
                        vout(ix,3,3) = 1./d(ix).*A33(ix);
                    else
                        f_fprintf(1,'Cannot inverse !',0,'\n');
                    end
                end
            else
                f_fprintf(1,'Cannot inverse !',0,'\n');
            end
            % --- 
            if any(isinf(vout))
                f_fprintf(1,'Inverse has Inf ! \n');
            end
            % --- 
            if any(isnan(vout))
                f_fprintf(1,'Inverse has NaN ! \n');
            end
            % ---
        end
        %------------------------------------------------------------------
        function vout = eval_fvectorized(obj,dom)
            %--------------------------------------------------------------
            f_ = obj.f;
            varargs = obj.varargin_list;
            fargs = obj.get_fargs(dom);
            %--------------------------------------------------------------
            vout = obj.cal(f_,'fargs',fargs,'varargs',varargs);
        end
        %------------------------------------------------------------------
        function vout = eval_fserial(obj,dom)
            % --- f_foreach
            %--------------------------------------------------------------
            f_ = obj.f;
            nb_fargin = f_nargin(obj.f);
            varargs = obj.varargin_list;
            fargs = obj.get_fargs(dom);
            %--------------------------------------------------------------
            nb_arg = length(fargs);
            %--------------------------------------------------------------
            nb_elem__ = zeros(1,nb_arg);
            size_arg = {};
            len_size = {};
            for i = 1:nb_arg
                size_arg{i}  = size(fargs{i});
                len_size{i}  = length(size_arg{i});
                nb_elem__(i) = max(size_arg{i});
            end
            %--------------------------------------------------------------
            nb_elem = max(nb_elem__);
            %--------------------------------------------------------------
            poidelem = zeros(1,nb_arg);
            for i = 1:nb_arg
                po = find(size_arg{i} == nb_elem);
                if ~isempty(po)
                    poidelem(i) = po(1);
                end
            end
            %--------------------------------------------------------------
            arg_pattern = {};
            for i = 1:nb_arg
                ap = '(';
                for j = 1:len_size{i}
                    if j == poidelem(i)
                        ap = [ap 'id_elem,'];
                    else
                        ap = [ap ':,'];
                    end
                end
                ap(end) = [];
                ap = [ap ')'];
                arg_pattern{i} = ap;
            end
            %--------------------------------------------------------------
            % Test
            a = {};
            for i = 1:nb_fargin
                id_elem = 1;
                eval(['a{i} = fargs{i}' arg_pattern{i} ';']);
            end
            %--------------------------------------------------------------
            vtest = obj.cal(f_,'fargs',a,'varargs',varargs);
            %--------------------------------------------------------------
            sizev = size(vtest);
            vout  = zeros([nb_elem sizev]);
            if numel(vtest) == 1
                len_size_vout = 1;
            else
                len_size_vout = length(sizev);
            end
            %--------------------------------------------------------------
            vout_pattern = '(id_elem,';
            for i = 1:len_size_vout
                vout_pattern = [vout_pattern ':,'];
            end
            vout_pattern(end) = [];
            vout_pattern = [vout_pattern ')'];
            %--------------------------------------------------------------
            if isempty(nb_elem)
                if nb_fargin == 0
                    vout = f_();
                else
                    vout = [];
                end
            else
                for id_elem = 1:nb_elem
                    %------------------------------------------------------
                    a = {};
                    for i = 1:nb_fargin
                        eval(['a{i} = fargs{i}' arg_pattern{i} ';']);
                    end
                    %------------------------------------------------------
                    varargs_is_empty = 0;
                    if iscell(varargs)
                        if isempty(varargs{1})
                            varargs_is_empty = 1;
                        end
                    elseif isempty(varargs)
                        varargs_is_empty = 1;
                    end
                    %------------------------------------------------------
                    if varargs_is_empty
                        if nb_fargin == 0
                            eval(['vout' vout_pattern '= f_();']);
                        elseif nb_fargin == 1
                            eval(['vout' vout_pattern '= f_(a{1});']);
                        elseif nb_fargin == 2
                            eval(['vout' vout_pattern '= f_(a{1},a{2});']);
                        elseif nb_fargin == 3
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3});']);
                        elseif nb_fargin == 4
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4});']);
                        elseif nb_fargin == 5
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5});']);
                        elseif nb_fargin == 6
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6});']);
                        elseif nb_fargin == 7
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7});']);
                        elseif nb_fargin == 8
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8});']);
                        elseif nb_fargin == 9
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8},a{9});']);
                        elseif nb_fargin == 10
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8},a{9},a{10});']);
                        end
                    else
                        if nb_fargin == 0
                            eval(['vout' vout_pattern '= f_(varargs{:});']);
                        elseif nb_fargin == 1
                            eval(['vout' vout_pattern '= f_(a{1},varargs{:});']);
                        elseif nb_fargin == 2
                            eval(['vout' vout_pattern '= f_(a{1},a{2},varargs{:});']);
                        elseif nb_fargin == 3
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},varargs{:});']);
                        elseif nb_fargin == 4
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},varargs{:});']);
                        elseif nb_fargin == 5
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},varargs{:});']);
                        elseif nb_fargin == 6
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},varargs{:});']);
                        elseif nb_fargin == 7
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},varargs{:});']);
                        elseif nb_fargin == 8
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8},varargs{:});']);
                        elseif nb_fargin == 9
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8},a{9},varargs{:});']);
                        elseif nb_fargin == 10
                            eval(['vout' vout_pattern '= f_(a{1},a{2},a{3},a{4},a{5},a{6},a{7},a{8},a{9},a{10},varargs{:});']);
                        end
                    end
                end
            end
            %--------------------------------------------------------------
            vout = squeeze(vout);
        end
        %------------------------------------------------------------------
        function fargs = get_fargs(obj,dom)
            % ---
            if f_nargin(obj.f) == 0
                fargs = [];
                return
            end
            % ---
            if isa(dom,'VolumeDom')
                id_elem = dom.gid_elem;
            elseif isa(dom,'SurfaceDom')
                id_elem = dom.gid_face;
            elseif isprop(dom,'gid_elem')
                id_elem = dom.gid_elem;
            elseif isprop(dom,'gid_face')
                id_elem = dom.gid_face;
            else
                id_elem = 1;
            end
            % ---
            fargs = cell(1,length(obj.depend_on));
            % ---
            parent_model_ = obj.parent_model;
            % ---
            depon__ = obj.depend_on;
            from__  = obj.from;
            for i = 1:length(depon__)
                depon_ = depon__{i};
                from_  = from__{i};
                if any(f_strcmpi(depon_,{'celem','cface','cedge','velem','sface','ledge'}))
                    % take from paramater parent_model's mesh
                    fargs{i} = parent_model_.parent_mesh.(depon_)(:,id_elem);
                elseif any(f_strcmpi(depon_,{...
                        'J','V','T','B','E','H','A','P','Phi'}))
                    % physical quantities
                    % must be able to take from other model with different ltime, mesh/dom
                    % ---
                    if isequal(from_, parent_model_)
                        % no interpolation
                        try
                            fargs{i} = from_.field{parent_model_.ltime.it}.(depon_).elem.cvalue(:,id_elem);
                        catch
                            fargs{i} = from_.field{parent_model_.ltime.it}.(depon_).elem.cvalue(id_elem);
                        end
                    else
                        if isequal(from_.parent_mesh, parent_model_.parent_mesh)
                            if isequal(from_.ltime.t_array, parent_model_.ltime.t_array)
                                % no interpolation
                                try
                                    fargs{i} = from_.field{parent_model_.ltime.it}.(depon_).elem.cvalue(:,id_elem);
                                catch
                                    fargs{i} = from_.field{parent_model_.ltime.it}.(depon_).elem.cvalue(id_elem);
                                end
                            else
                                % get by time interpolation
                                next_it = from_.ltime.next_it(parent_model_.ltime.t_now);
                                back_it = from_.ltime.back_it(parent_model_.ltime.t_now);
                                if next_it == back_it
                                    try
                                        fargs{i} = from_.field{back_it}.(depon_).elem.cvalue(:,id_elem);
                                    catch
                                        fargs{i} = from_.field{back_it}.(depon_).elem.cvalue(id_elem);
                                    end
                                else
                                    % ---
                                    try
                                        val01 = from_.field{back_it}.(depon_).elem.cvalue(:,id_elem);
                                        val02 = from_.field{next_it}.(depon_).elem.cvalue(:,id_elem);
                                    catch
                                        val01 = from_.field{back_it}.(depon_).elem.cvalue(id_elem);
                                        val02 = from_.field{next_it}.(depon_).elem.cvalue(id_elem);
                                    end
                                    % ---
                                    delta_v = val02 - val01;
                                    % ---
                                    delta_t = from_.ltime.t_array(next_it) - from_.ltime.t_array(back_it);
                                    % ---
                                    dt = parent_model_.ltime.t_now - from_.ltime.t_array(back_it);
                                    fargs{i} = val01 + delta_v./delta_t .* dt;
                                end
                            end
                        else
                            % get by time/mesh interpolation
                            % --- take just what needed
                            id_elem_i = f_findelem(from_.parent_mesh.node,from_.parent_mesh.elem,...
                                        'in_box',parent_model_.parent_mesh.localbox(id_elem));
                            % --- time interpolated data
                            next_it = from_.ltime.next_it(parent_model_.ltime.t_now);
                            back_it = from_.ltime.back_it(parent_model_.ltime.t_now);
                            if next_it == back_it
                                valcell = from_.field{back_it}.(depon_).elem.ivalue;
                            else
                                % ---
                                val01 = from_.field{back_it}.(depon_).elem.ivalue;
                                val02 = from_.field{next_it}.(depon_).elem.ivalue;
                                % ---
                                delta_v = [];
                                for k = 1:length(val01)
                                    delta_v{k} = val02{k} - val01{k};
                                end
                                % ---
                                delta_t = from_.ltime.t_array(next_it) - from_.ltime.t_array(back_it);
                                % ---
                                dt = parent_model_.ltime.t_now - from_.ltime.t_array(back_it);
                                % ---
                                for k = 1:length(val01)
                                    valcell{k} = val01{k} + delta_v{k}./delta_t .* dt;
                                end
                                % ---
                            end
                            % --- space interpolation
                            nbINoinEl = from_.parent_mesh.refelem.nbI;
                            nb_elem   = length(id_elem_i);
                            % ---
                            node_i = zeros(nbINoinEl * nb_elem, 3);
                            % ---
                            interp_node = from_.parent_mesh.prokit.node;
                            % ---
                            id0 = 1:nb_elem;
                            for k = 1:nbINoinEl
                                idn = id0 + (k - 1) * nb_elem;
                                node_i(idn,:) = interp_node{k}(id_elem_i,:);
                            end
                            % ---
                            dim_ = size(valcell{1},1);
                            if dim_ == 1
                                valx = zeros(nbINoinEl * nb_elem, 1);
                                % ---
                                id0 = 1:nb_elem;
                                for k = 1:nbINoinEl
                                    idn = id0 + (k - 1) * nb_elem;
                                    valx(idn) = valcell{k}(1,id_elem_i);
                                end
                                % ---
                                fxi = scatteredInterpolant(node_i,valx,'linear','none');
                                % ---
                                cnode_ = parent_model_.parent_mesh.celem(:,id_elem);
                                fargs{i} = fxi(cnode_.');
                                % ---
                            elseif dim_ == 2
                                valx = zeros(nbINoinEl * nb_elem, 1);
                                valy = zeros(nbINoinEl * nb_elem, 1);
                                % ---
                                id0 = 1:nb_elem;
                                for k = 1:nbINoinEl
                                    idn = id0 + (k - 1) * nb_elem;
                                    valx(idn) = valcell{k}(1,id_elem_i);
                                    valy(idn) = valcell{k}(2,id_elem_i);
                                end
                                % ---
                                fxi = scatteredInterpolant(node_i,valx,'linear','none');
                                fyi = fxi;
                                fyi.Values = valy;
                                % ---
                                cnode_ = parent_model_.parent_mesh.celem(:,id_elem);
                                vx_ = fxi(cnode_.');
                                vy_ = fyi(cnode_.');
                                fargs{i} = [vx_ vy_];
                                % ---
                            elseif dim_ == 3
                                valx = zeros(nbINoinEl * nb_elem, 1);
                                valy = zeros(nbINoinEl * nb_elem, 1);
                                valz = zeros(nbINoinEl * nb_elem, 1);
                                % ---
                                id0 = 1:nb_elem;
                                for k = 1:nbINoinEl
                                    idn = id0 + (k - 1) * nb_elem;
                                    valx(idn) = valcell{k}(1,id_elem_i);
                                    valy(idn) = valcell{k}(2,id_elem_i);
                                    valz(idn) = valcell{k}(3,id_elem_i);
                                end
                                % ---
                                fxi = scatteredInterpolant(node_i,valx,'linear','none');
                                fyi = fxi;
                                fyi.Values = valy;
                                fzi = fxi;
                                fzi.Values = valz;
                                % ---
                                cnode_ = parent_model_.parent_mesh.celem(:,id_elem);
                                vx_ = fxi(cnode_.');
                                vy_ = fyi(cnode_.');
                                vz_ = fzi(cnode_.');
                                fargs{i} = [vx_ vy_ vz_];
                                % ---
                            end
                        end
                    end
                elseif any(f_strcmpi(depon_,{'ltime','time'}))
                    % take from parent_model of paramater object
                    fargs{i} = parent_model_.ltime.t_now;
                end
            end
        end
        %------------------------------------------------------------------
        function vout = cal(obj,fhand,args)
            arguments
                obj
                fhand
                args.fargs = []
                args.varargs = []
            end
            f_ = fhand;
            nb_fargin = f_nargin(fhand);
            varargs = args.varargs;
            fargs = args.fargs;
            %--------------------------------------------------------------
            varargs_is_empty = 0;
            if iscell(varargs)
                if isempty(varargs{1})
                    varargs_is_empty = 1;
                end
            elseif isempty(varargs)
                varargs_is_empty = 1;
            end
            %--------------------------------------------------------------
            if varargs_is_empty
                if nb_fargin == 0
                    vout = f_();
                elseif nb_fargin == 1
                    vout = f_(fargs{1});
                elseif nb_fargin == 2
                    vout = f_(fargs{1},fargs{2});
                elseif nb_fargin == 3
                    vout = f_(fargs{1},fargs{2},fargs{3});
                elseif nb_fargin == 4
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4});
                elseif nb_fargin == 5
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5});
                elseif nb_fargin == 6
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6});
                elseif nb_fargin == 7
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7});
                elseif nb_fargin == 8
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8});
                elseif nb_fargin == 9
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8},fargs{9});
                elseif nb_fargin == 10
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8},fargs{9},fargs{10});
                end
            else
                if nb_fargin == 0
                    vout = f_(varargs{:});
                elseif nb_fargin == 1
                    vout = f_(fargs{1},varargs{:});
                elseif nb_fargin == 2
                    vout = f_(fargs{1},fargs{2},varargs{:});
                elseif nb_fargin == 3
                    vout = f_(fargs{1},fargs{2},fargs{3},varargs{:});
                elseif nb_fargin == 4
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},varargs{:});
                elseif nb_fargin == 5
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},varargs{:});
                elseif nb_fargin == 6
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},varargs{:});
                elseif nb_fargin == 7
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},varargs{:});
                elseif nb_fargin == 8
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8},varargs{:});
                elseif nb_fargin == 9
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8},fargs{9},varargs{:});
                elseif nb_fargin == 10
                    vout = f_(fargs{1},fargs{2},fargs{3},fargs{4},fargs{5},fargs{6},fargs{7},fargs{8},fargs{9},fargs{10},varargs{:});
                end
            end
        end
        %------------------------------------------------------------------

    end
end