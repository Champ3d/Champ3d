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

classdef Parameter < Xhandle
    properties
        parent_model
        f
        depend_on
        from
        varargin_list
        fvectorized
        % ---
        dit
        id_coil
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','f','depend_on','at_it','from','varargin_list','fvectorized'};
        end
    end
    % --- Contructor
    methods
        function obj = Parameter(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,{'PhysicalModel','CplModel'})}
                args.f
                args.depend_on
                args.from
                args.varargin_list
                args.fvectorized
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isempty(fieldnames(args))
                argu = f_to_namedarg(args);
                obj.setup(argu{:});
            end
            % ---
        end
    end
    % --- setup
    methods (Access = protected)
        function setup(obj,args)
            arguments
                obj
                args.parent_model = []
                args.f = []
                args.depend_on = ''
                args.from = []
                args.varargin_list = []
                args.fvectorized = 0
            end
            % ---
            parent_model_ = args.parent_model;
            varargin_list_ = args.varargin_list;
            fvectorized_ = args.fvectorized;
            % ---
            % if isempty(args.f)
            %     error('#f must be given ! Give a function handle or numeric value');
            % end
            % ---
            from_ = [];
            if isnumeric(args.f)
                const = args.f;
                % ---
                sizeconst = size(const);
                % ---
                if numel(const) == 1 || isempty(const)
                    f_ = @()(const);
                elseif numel(const) == 2 || numel(const) == 3
                    const = f_tocolv(const);
                    f_ = @()(const);
                elseif isequal(sizeconst,[2 2]) || isequal(sizeconst,[3 3])
                    f_ = @()(const);
                else
                    fprintf(['Constant parameter must be a single scalar, ' ...
                             'single vector or single tensor !\n' ...
                             'Consider ScalarParameter, VectorParameter or TensorParameter ' ...
                             'for general purpose. \n']);
                    error('constant parameter error');
                end
            elseif isa(args.f,'function_handle')
                f_ = args.f;
                if isempty(args.from)
                    args.depend_on = f_to_scellargin(args.depend_on);
                    depon_is_all_free_param = 1;
                    for idepon = 1:length(args.depend_on)
                        if ~isa(args.depend_on{idepon},'Parameter')
                            depon_is_all_free_param = 0;
                        end
                    end
                    if ~depon_is_all_free_param
                        error('#from must be given ! Give EMModel, THModel, ... ');
                    end
                else
                    from_ = f_to_scellargin(args.from);
                end
            else
                error('#f must be function handle or numeric value');
            end
            % ---
            % depend_on =
            % 'celem','cface','velem','sface','ledge'}
            % 'E', 'E(0)', {'E(0)','E(-1)'}, {'E(0)','E(-1)','V(0).id_coil'}
            % ---> idem. with : 'B','T','P','E','H','J','I','Z','A','Phi'
            % 'ltime'
            % ---
            depon = f_to_scellargin(args.depend_on);
            % ---
            len_depon  = length(depon);
            depend_on_ = cell(1,len_depon);
            dit_       = cell(1,len_depon);
            id_coil_   = cell(1,len_depon);
            % ---
            for i = 1:length(depon)
                if isa(depon{i},'Parameter')
                    depend_on_{i} = depon{i};
                elseif ischar(depon{i})
                    str00 = depon{i};
                    % ---
                    str00 = split(str00,'.');
                    % ---
                    if length(str00) == 2
                        id_coil_{i} = str00{2};
                    elseif length(str00) == 1
                        id_coil_{i} = '';
                    else
                        error("#depend_on must be of form : 'celem','B','B(i)','V.id_coil','V(i).id_coil','ltime',...");
                    end
                    % ---
                    str00 = str00{1};
                    % ---
                    if contains(str00,'(')
                        str01 = extractBetween(str00,'','(');
                        depend_on_{i} = str01{1};
                        % ---
                        str02 = extractBetween(str00,'(',')');
                        dit_{i} = str2double(str02{1});
                    else
                        depend_on_{i} = str00;
                        dit_{i} = 0;
                    end
                else
                    error('#depend_on must be char or Parameter');
                end
            end
            % --- check
            nb_fargin = f_nargin(f_);
            if nb_fargin > 0
                if nb_fargin ~= length(depend_on_)
                    error('Number of input arguments of #f must corresponds to #depend_on');
                end
                % ---
                depon_is_all_free_param = 1;
                for idepon = 1:length(depend_on_)
                    if ~isa(depend_on_{idepon},'Parameter')
                        depon_is_all_free_param = 0;
                    end
                end
                % ---
                if ~depon_is_all_free_param
                    len_from = length(from_);
                    if len_from ~= len_depon
                        if len_from == 1
                            for i = 1:len_depon
                                from_{i} = from_{1};
                            end
                        else
                            error('Size if #from must be coherent with #depend_on');
                        end
                    end
                end
                % ---
            end
            % ---
            obj.parent_model = parent_model_;
            obj.f = f_;
            obj.depend_on = depend_on_;
            obj.dit = dit_;
            obj.id_coil = id_coil_;
            obj.from = from_;
            obj.varargin_list = varargin_list_;
            obj.fvectorized = fvectorized_;
            % ---
        end
    end
    % --- get
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
            else
                vout = obj.eval_fserial(dom);
            end
            % ---
        end
        %------------------------------------------------------------------
    end
    %----------------------------------------------------------------------
    methods (Access = private)
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
            % -------------------------------------------------------------
            parameter_dependency_search = [];
            meshdom = [];
            place = [];
            id_place_target = [];
            if ~isempty(dom)
                if isa(dom,'PhysicalDom')
                    meshdom = dom.dom;
                    parameter_dependency_search = dom.parameter_dependency_search;
                else
                    meshdom = dom;
                end
                % ---
                if isempty(parameter_dependency_search)
                    parameter_dependency_search = 'by_coordinates';
                end
                % ---
                if isa(meshdom,'VolumeDom')
                    place = 'elem';
                    id_place_target = meshdom.gindex;
                elseif isa(meshdom,'SurfaceDom')
                    place = 'face';
                    id_place_target = meshdom.gindex;
                else
                    error('must give #dom with .gindex or .gindex !');
                end
            end
            % -------------------------------------------------------------
            fargs = cell(1,length(obj.depend_on));
            % -------------------------------------------------------------
            % --- free defined parameter
            if isempty(obj.parent_model)
                % --- free defined parameter
                for i = 1:length(obj.depend_on)
                    if isa(obj.depend_on{i},'Parameter')
                        fargs{i} = obj.depend_on{i}.getvalue;
                    else
                        pvalue__ = obj.from{i}.(obj.depend_on{i});
                        if isnumeric(pvalue__)
                            fargs{i} = pvalue__;
                        elseif isa(pvalue__,'Parameter')
                            fargs{i} = pvalue__.getvalue;
                        else
                            fargs{i} = [];
                        end
                    end
                end
                return
            end
            % -------------------------------------------------------------
            target_dom   = meshdom;
            target_model = obj.parent_model;
            % ---
            depon__   = obj.depend_on;
            id_coil__ = obj.id_coil;
            dit__     = obj.dit;
            source_model_  = obj.from;
            % -------------------------------------------------------------
            for i = 1:length(depon__)
                % ---
                depon_       = depon__{i};
                % ---
                if isa(depon_,'Parameter')
                    fargs{i} = depon_.getvalue;
                    continue;
                end
                % ---
                id_coil_     = id_coil__{i};
                dit_         = dit__{i};
                source_model = source_model_{i};
                % ---
                if any(f_strcmpi(depon_,{'celem','cface','cedge','velem','sface','ledge'}))
                    % take from paramater parent_model's mesh
                    fargs{i} = target_model.parent_mesh.(depon_)(:,id_place_target);
                elseif any(f_strcmpi(depon_,{'ltime','time'}))
                    % take from parent_model of paramater object
                    fargs{i} = target_model.ltime.t_now;
                elseif any(f_strcmpi(depon_,{'fr'}))
                    % take from parent_model of paramater object
                    fargs{i} = target_model.fr;
                elseif any(f_strcmpi(depon_,{'V','I','Z'}))
                    % ---
                    if ~isprop(source_model,'coil')
                        error('no coil in source model !');
                    else
                        if ~isfield(source_model.coil,id_coil_)
                            error(['no #coil ' id_coil_ ' in source model !'])
                        end
                    end
                    % get by time interpolation
                    next_it = source_model.ltime.next_it(target_model.ltime.t_now);
                    back_it = source_model.ltime.back_it(target_model.ltime.t_now);
                    if next_it == back_it
                        fargs{i} = source_model.coil.(id_coil_).(depon_){back_it};
                    else
                        % ---
                        val01 = source_model.coil.(id_coil_).(depon_){back_it};
                        val02 = source_model.coil.(id_coil_).(depon_){next_it};
                        % ---
                        delta_v = val02 - val01;
                        delta_t = source_model.ltime.t_array(next_it) - source_model.ltime.t_array(back_it);
                        % ---
                        dt = target_model.ltime.t_now - source_model.ltime.t_array(back_it);
                        fargs{i} = val01 + delta_v./delta_t .* dt;
                    end
                    % --------------------------------------
                elseif any(f_strcmpi(depon_,{...
                        'J','T','B','E','H','A','P','Phi'}))
                    % physical quantities
                    % must be able to take from other model with different ltime, mesh/dom
                    % ---
                    target_it = target_model.ltime.it - dit_;
                    it_max = target_model.ltime.it_max;
                    target_it = min(it_max,max(1,target_it));
                    target_t = target_model.ltime.t_at(target_it);
                    % ---
                    if isequal(source_model, target_model)
                        % no interpolation
                        fargs{i} = source_model.field{target_it}.(depon_).(place).cvalue(id_place_target);
                    else
                        if isequal(source_model.parent_mesh, target_model.parent_mesh)
                            if isequal(source_model.ltime.t_array, target_model.ltime.t_array)
                                % no interpolation
                                fargs{i} = source_model.field{target_it}.(depon_).(place).cvalue(id_place_target);
                            else
                                % get by time interpolation
                                next_it = source_model.ltime.next_it(target_t);
                                back_it = source_model.ltime.back_it(target_t);
                                if next_it == back_it
                                    fargs{i} = source_model.field{back_it}.(depon_).(place).cvalue(id_place_target);
                                else
                                    % ---
                                    val01 = source_model.field{back_it}.(depon_).(place).cvalue(id_place_target);
                                    val02 = source_model.field{next_it}.(depon_).(place).cvalue(id_place_target);
                                    % ---
                                    delta_v = val02 - val01;
                                    % ---
                                    delta_t = source_model.ltime.t_array(next_it) - source_model.ltime.t_array(back_it);
                                    % ---
                                    dt = target_t - source_model.ltime.t_array(back_it);
                                    fargs{i} = val01 + delta_v./delta_t .* dt;
                                end
                            end
                        else
                            % get by time/mesh interpolation
                            if f_strcmpi(place,'elem')
                                % ---
                                id_elem_target = id_place_target;
                                % --- take just what needed
                                if f_strcmpi(parameter_dependency_search,'by_coordinates')
                                    id_elem_source = f_findelem(source_model.parent_mesh.node,source_model.parent_mesh.elem,...
                                                'in_box',target_model.parent_mesh.localbox(id_elem_target));
                                elseif f_strcmpi(parameter_dependency_search,'by_id_dom')
                                    id_elem_source = [];
                                    id_dom_source = fieldnames(source_model.parent_mesh.dom);
                                    for ids = 1:length(id_dom_source)
                                        if f_strcmpi(id_dom_source{ids},target_dom.id)
                                            id_elem_source = source_model.parent_mesh.dom.(id_dom_source{ids}).gindex;
                                        end
                                    end
                                    if isempty(id_elem_source)
                                        f_fprintf(0,'volumedom',1,target_dom.id,0,'not found on source model !',...
                                            0,'champ3d performs #parameter_dependency_search by_coordinates \n');
                                            id_elem_source = f_findelem(source_model.parent_mesh.node,source_model.parent_mesh.elem,...
                                                'in_box',target_model.parent_mesh.localbox(id_elem_target));
                                    end
                                end
                                % --- time interpolated data
                                next_it = source_model.ltime.next_it(target_t);
                                back_it = source_model.ltime.back_it(target_t);
                                if next_it == back_it
                                    valcell = source_model.field{back_it}.(depon_).elem.ivalue(id_elem_source);
                                else
                                    % ---
                                    val01 = source_model.field{back_it}.(depon_).elem.ivalue(id_elem_source);
                                    val02 = source_model.field{next_it}.(depon_).elem.ivalue(id_elem_source);
                                    % ---
                                    delta_v = [];
                                    for k = 1:length(val01)
                                        delta_v{k} = val02{k} - val01{k};
                                    end
                                    % ---
                                    delta_t = source_model.ltime.t_array(next_it) - source_model.ltime.t_array(back_it);
                                    % ---
                                    dt = target_t - source_model.ltime.t_array(back_it);
                                    % ---
                                    for k = 1:length(val01)
                                        valcell{k} = val01{k} + delta_v{k}./delta_t .* dt;
                                    end
                                    % ---
                                end
                                % --- space interpolation
                                interp_node = source_model.parent_mesh.prokit.node;
                                nbINode = length(interp_node);
                                nb_elem   = length(id_elem_source);
                                % ---
                                node_i = zeros(nbINode * nb_elem, 3);
                                % ---
                                id0 = 1:nb_elem;
                                for k = 1:nbINode
                                    idn = id0 + (k - 1) * nb_elem;
                                    node_i(idn,:) = interp_node{k}(id_elem_source,:);
                                end
                                % ---
                                dim_ = size(valcell{1},2);
                                if dim_ == 1
                                    valx = zeros(nbINode * nb_elem, 1);
                                    % ---
                                    id0 = 1:nb_elem;
                                    for k = 1:nbINode
                                        idn = id0 + (k - 1) * nb_elem;
                                        valx(idn) = valcell{k}(:,1);
                                    end
                                    % ---
                                    fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                    % ---
                                    cnode_ = target_model.parent_mesh.celem(:,id_elem_target);
                                    fargs{i} = fxi(cnode_.');
                                    % ---
                                elseif dim_ == 2
                                    valx = zeros(nbINode * nb_elem, 1);
                                    valy = zeros(nbINode * nb_elem, 1);
                                    % ---
                                    id0 = 1:nb_elem;
                                    for k = 1:nbINode
                                        idn = id0 + (k - 1) * nb_elem;
                                        valx(idn) = valcell{k}(:,1);
                                        valy(idn) = valcell{k}(:,2);
                                    end
                                    % ---
                                    fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                    fyi = fxi;
                                    fyi.Values = valy;
                                    % ---
                                    cnode_ = target_model.parent_mesh.celem(:,id_elem_target);
                                    vx_ = fxi(cnode_.');
                                    vy_ = fyi(cnode_.');
                                    fargs{i} = [vx_ vy_];
                                    % ---
                                elseif dim_ == 3
                                    valx = zeros(nbINode * nb_elem, 1);
                                    valy = zeros(nbINode * nb_elem, 1);
                                    valz = zeros(nbINode * nb_elem, 1);
                                    % ---
                                    id0 = 1:nb_elem;
                                    for k = 1:nbINode
                                        idn = id0 + (k - 1) * nb_elem;
                                        valx(idn) = valcell{k}(:,1);
                                        valy(idn) = valcell{k}(:,2);
                                        valz(idn) = valcell{k}(:,3);
                                    end
                                    % ---
                                    fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                    fyi = fxi;
                                    fyi.Values = valy;
                                    fzi = fxi;
                                    fzi.Values = valz;
                                    % ---
                                    cnode_ = target_model.parent_mesh.celem(:,id_elem_target);
                                    vx_ = fxi(cnode_.');
                                    vy_ = fyi(cnode_.');
                                    vz_ = fzi(cnode_.');
                                    fargs{i} = [vx_ vy_ vz_];
                                    % ---
                                end
                            elseif f_strcmpi(place,'face')
                                % ---
                                id_face_target = id_place_target;
                                % --- take just what needed
                                id_face_source = [];
                                id_elem_source = [];
                                if f_strcmpi(parameter_dependency_search,'by_coordinates')
                                    id_elem_source = f_findelem(source_model.parent_mesh.node,source_model.parent_mesh.elem,...
                                                'in_box',target_model.parent_mesh.localbox);
                                elseif f_strcmpi(parameter_dependency_search,'by_id_dom')
                                    id_dom_source = fieldnames(source_model.parent_mesh.dom);
                                    for ids = 1:length(id_dom_source)
                                        if f_strcmpi(id_dom_source{ids},target_dom.id)
                                            id_face_source = source_model.parent_mesh.dom.(id_dom_source{ids}).gindex;
                                        end
                                    end
                                    if isempty(id_face_source)
                                        f_fprintf(0,'surfacedom',1,target_dom.id,0,'not found on source model !',...
                                            0,'champ3d performs #parameter_dependency_search by_coordinates \n');
                                            id_elem_source = f_findelem(source_model.parent_mesh.node,source_model.parent_mesh.elem,...
                                                'in_box',target_model.parent_mesh.localbox);
                                    end
                                end
                                % ------------------------------------------------------------------
                                if ~isempty(id_face_source)
                                    % --- time interpolated data
                                    next_it = source_model.ltime.next_it(target_t);
                                    back_it = source_model.ltime.back_it(target_t);
                                    if next_it == back_it
                                        valcell = source_model.field{back_it}.(depon_).face.ivalue(id_face_source);
                                    else
                                        % ---
                                        val01 = source_model.field{back_it}.(depon_).face.ivalue(id_face_source);
                                        val02 = source_model.field{next_it}.(depon_).face.ivalue(id_face_source);
                                        % ---
                                        delta_v = [];
                                        for k = 1:length(val01)
                                            delta_v{k} = val02{k} - val01{k};
                                        end
                                        % ---
                                        delta_t = source_model.ltime.t_array(next_it) - source_model.ltime.t_array(back_it);
                                        % ---
                                        dt = target_t - source_model.ltime.t_array(back_it);
                                        % ---
                                        for k = 1:length(val01)
                                            valcell{k} = val01{k} + delta_v{k}./delta_t .* dt;
                                        end
                                        % ---
                                    end
                                    % --- space interpolation
                                    % --- take interp_node from Field
                                    interp_node = source_model.field{back_it}.(depon_).face.inode(id_face_source);
                                    nbINode = length(interp_node);
                                    nb_face = length(id_face_source);
                                    % ---
                                    node_i = zeros(nbINode * nb_face, 3);
                                    % ---
                                    id0 = 1:nb_face;
                                    for k = 1:nbINode
                                        idn = id0 + (k - 1) * nb_face;
                                        node_i(idn,:) = interp_node{k};
                                    end
                                    % ---
                                    dim_ = size(valcell{1},2);
                                    if dim_ == 1
                                        valx = zeros(nbINode * nb_face, 1);
                                        % ---
                                        id0 = 1:nb_face;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_face;
                                            valx(idn) = valcell{k}(:,1);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        fargs{i} = fxi(cnode_.');
                                        % ---
                                    elseif dim_ == 2
                                        valx = zeros(nbINode * nb_face, 1);
                                        valy = zeros(nbINode * nb_face, 1);
                                        % ---
                                        id0 = 1:nb_face;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_face;
                                            valx(idn) = valcell{k}(:,1);
                                            valy(idn) = valcell{k}(:,2);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        fyi = fxi;
                                        fyi.Values = valy;
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        vx_ = fxi(cnode_.');
                                        vy_ = fyi(cnode_.');
                                        fargs{i} = [vx_ vy_];
                                        % ---
                                    elseif dim_ == 3
                                        valx = zeros(nbINode * nb_face, 1);
                                        valy = zeros(nbINode * nb_face, 1);
                                        valz = zeros(nbINode * nb_face, 1);
                                        % ---
                                        id0 = 1:nb_face;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_face;
                                            valx(idn) = valcell{k}(:,1);
                                            valy(idn) = valcell{k}(:,2);
                                            valz(idn) = valcell{k}(:,3);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        fyi = fxi;
                                        fyi.Values = valy;
                                        fzi = fxi;
                                        fzi.Values = valz;
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        vx_ = fxi(cnode_.');
                                        vy_ = fyi(cnode_.');
                                        vz_ = fzi(cnode_.');
                                        fargs{i} = [vx_ vy_ vz_];
                                        % ---
                                    end
                                    % --------------------------------------------------------------
                                elseif ~isempty(id_elem_source)
                                    % --- XTODO : not optimat code writing/organization
                                    % --- time interpolated data
                                    next_it = source_model.ltime.next_it(target_t);
                                    back_it = source_model.ltime.back_it(target_t);
                                    if next_it == back_it
                                        valcell = source_model.field{back_it}.(depon_).elem.ivalue(id_elem_source);
                                    else
                                        % ---
                                        val01 = source_model.field{back_it}.(depon_).elem.ivalue(id_elem_source);
                                        val02 = source_model.field{next_it}.(depon_).elem.ivalue(id_elem_source);
                                        % ---
                                        delta_v = [];
                                        for k = 1:length(val01)
                                            delta_v{k} = val02{k} - val01{k};
                                        end
                                        % ---
                                        delta_t = source_model.ltime.t_array(next_it) - source_model.ltime.t_array(back_it);
                                        % ---
                                        dt = target_t - source_model.ltime.t_array(back_it);
                                        % ---
                                        for k = 1:length(val01)
                                            valcell{k} = val01{k} + delta_v{k}./delta_t .* dt;
                                        end
                                        % ---
                                    end
                                    % --- space interpolation
                                    interp_node = source_model.parent_mesh.prokit.node;
                                    nbINode = length(interp_node);
                                    nb_elem = length(id_elem_source);
                                    % ---
                                    node_i = zeros(nbINode * nb_elem, 3);
                                    % ---
                                    id0 = 1:nb_elem;
                                    for k = 1:nbINode
                                        idn = id0 + (k - 1) * nb_elem;
                                        node_i(idn,:) = interp_node{k}(id_elem_source,:);
                                    end
                                    % ---
                                    dim_ = size(valcell{1},2);
                                    if dim_ == 1
                                        valx = zeros(nbINode * nb_elem, 1);
                                        % ---
                                        id0 = 1:nb_elem;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_elem;
                                            valx(idn) = valcell{k}(:,1);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        fargs{i} = fxi(cnode_.');
                                        % ---
                                    elseif dim_ == 2
                                        valx = zeros(nbINode * nb_elem, 1);
                                        valy = zeros(nbINode * nb_elem, 1);
                                        % ---
                                        id0 = 1:nb_elem;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_elem;
                                            valx(idn) = valcell{k}(:,1);
                                            valy(idn) = valcell{k}(:,2);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        fyi = fxi;
                                        fyi.Values = valy;
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        vx_ = fxi(cnode_.');
                                        vy_ = fyi(cnode_.');
                                        fargs{i} = [vx_ vy_];
                                        % ---
                                    elseif dim_ == 3
                                        valx = zeros(nbINode * nb_elem, 1);
                                        valy = zeros(nbINode * nb_elem, 1);
                                        valz = zeros(nbINode * nb_elem, 1);
                                        % ---
                                        id0 = 1:nb_elem;
                                        for k = 1:nbINode
                                            idn = id0 + (k - 1) * nb_elem;
                                            valx(idn) = valcell{k}(:,1);
                                            valy(idn) = valcell{k}(:,2);
                                            valz(idn) = valcell{k}(:,3);
                                        end
                                        % ---
                                        fxi = scatteredInterpolant(node_i,valx,'linear','linear');
                                        fyi = fxi;
                                        fyi.Values = valy;
                                        fzi = fxi;
                                        fzi.Values = valz;
                                        % ---
                                        cnode_ = target_model.parent_mesh.cface(:,id_face_target);
                                        vx_ = fxi(cnode_.');
                                        vy_ = fyi(cnode_.');
                                        vz_ = fzi(cnode_.');
                                        fargs{i} = [vx_ vy_ vz_];
                                        % ---
                                    end
                                end
                                % ------------------------------------------------------------------
                            end
                        end
                    end
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