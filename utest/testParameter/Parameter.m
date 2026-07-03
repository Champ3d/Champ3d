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
    % A Parameter evaluates a user function #f whose input arguments are
    % taken from other objects of the simulation.
    %
    % #f : numeric constant (scalar, 2/3-vector, 2x2/3x3 tensor)
    %      or function handle
    % #depend_on : one token per input argument of #f, among
    %   - a Parameter object (free parameter)
    %   - mesh data      : 'celem','cface','cedge','velem','sface','ledge'
    %   - time/frequency : 'ltime' (or 'time'), 'fr'
    %   - coil circuit   : 'V.id_coil','I.id_coil','Z.id_coil'
    %   - field data     : 'J','T','B','E','H','A','P','Phi'
    %     'B' or 'B(0)' means B at actual time step,
    %     'B(-1)','B(-2)', ... at previous time steps
    % #from : source model of each dependency
    %         (a single #from is expanded to all dependencies)

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
            % --- #f : numeric constant or function handle
            from_ = [];
            if isnumeric(args.f)
                f_ = Parameter.const_to_fhandle(args.f);
            elseif isa(args.f,'function_handle')
                f_ = args.f;
                if isempty(args.from)
                    if ~Parameter.is_all_parameter(f_to_scellargin(args.depend_on))
                        error('#from must be given ! Give EMModel, THModel, ... ');
                    end
                else
                    from_ = f_to_scellargin(args.from);
                end
            else
                error('#f must be function handle or numeric value');
            end
            % --- #depend_on : one parsed token per input argument of #f
            [depend_on_,dit_,id_coil_] = ...
                Parameter.parse_dependencies(f_to_scellargin(args.depend_on));
            % --- checks
            nb_fargin = f_nargin(f_);
            if nb_fargin > 0
                if nb_fargin ~= length(depend_on_)
                    error('Number of input arguments of #f must corresponds to #depend_on');
                end
                % ---
                if ~Parameter.is_all_parameter(depend_on_)
                    if length(from_) ~= length(depend_on_)
                        if length(from_) == 1
                            from_ = repmat(from_(1),1,length(depend_on_));
                        else
                            error('Size if #from must be coherent with #depend_on');
                        end
                    end
                end
            end
            % ---
            obj.parent_model = args.parent_model;
            obj.f = f_;
            obj.depend_on = depend_on_;
            obj.dit = dit_;
            obj.id_coil = id_coil_;
            obj.from = from_;
            obj.varargin_list = args.varargin_list;
            obj.fvectorized = args.fvectorized;
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
            if obj.fvectorized
                vout = obj.eval_fvectorized(args.in_dom);
            else
                vout = obj.eval_fserial(args.in_dom);
            end
            % ---
        end
        %------------------------------------------------------------------
    end

    %----------------------------------------------------------------------
    % --- evaluation of #f
    methods (Access = private)
        %------------------------------------------------------------------
        function vout = eval_fvectorized(obj,dom)
            fargs = obj.get_fargs(dom);
            vout = obj.cal(obj.f,'fargs',fargs,'varargs',obj.varargin_list);
        end
        %------------------------------------------------------------------
        function vout = eval_fserial(obj,dom)
            % evaluate #f entity per entity when it is not vectorized
            f_ = obj.f;
            nb_fargin = f_nargin(f_);
            varargs = obj.varargin_list;
            fargs = obj.get_fargs(dom);
            % --- number of entities = largest dimension found in arguments
            nb_arg = length(fargs);
            nb_elem_ = zeros(1,nb_arg);
            for i = 1:nb_arg
                nb_elem_(i) = max(size(fargs{i}));
            end
            nb_elem = max(nb_elem_);
            % --- no entity-wise argument at all
            if isempty(nb_elem)
                if nb_fargin == 0
                    vout = f_();
                else
                    vout = [];
                end
                return
            end
            % --- indexing template of each argument :
            %     ':' everywhere except on the entity dimension
            arg_subs = cell(1,nb_arg);
            elem_dim = zeros(1,nb_arg);
            for i = 1:nb_arg
                size_i = size(fargs{i});
                arg_subs{i} = repmat({':'},1,length(size_i));
                po = find(size_i == nb_elem,1);
                if ~isempty(po)
                    elem_dim(i) = po;
                end
            end
            % --- one probe evaluation to size the output
            a = Parameter.slice_fargs(fargs,arg_subs,elem_dim,1,nb_fargin);
            vtest = obj.cal(f_,'fargs',a,'varargs',varargs);
            % ---
            sizev = size(vtest);
            vout = zeros([nb_elem sizev]);
            if numel(vtest) == 1
                out_subs = {':'};
            else
                out_subs = repmat({':'},1,length(sizev));
            end
            % --- entity loop
            for id_elem = 1:nb_elem
                a = Parameter.slice_fargs(fargs,arg_subs,elem_dim,id_elem,nb_fargin);
                vout(id_elem,out_subs{:}) = obj.cal(f_,'fargs',a,'varargs',varargs);
            end
            % ---
            vout = squeeze(vout);
        end
        %------------------------------------------------------------------
        function vout = cal(~,fhand,args)
            arguments
                ~
                fhand
                args.fargs = []
                args.varargs = []
            end
            % ---
            nb_fargin = f_nargin(fhand);
            if nb_fargin > 0
                callargs = args.fargs(1:nb_fargin);
            else
                callargs = {};
            end
            % ---
            if ~Parameter.varargs_isempty(args.varargs)
                callargs = [callargs args.varargs];
            end
            % ---
            vout = fhand(callargs{:});
        end
    end

    %----------------------------------------------------------------------
    % --- collection of the input arguments of #f
    methods (Access = private)
        %------------------------------------------------------------------
        function fargs = get_fargs(obj,dom)
            % ---
            if f_nargin(obj.f) == 0
                fargs = [];
                return
            end
            % --- target support (elem/face) described by #dom
            [target_dom,place,id_place_target,dependency_search] = ...
                Parameter.resolve_target(dom);
            % --- free defined parameter
            if isempty(obj.parent_model)
                fargs = obj.get_fargs_free();
                return
            end
            % ---
            target_model = obj.parent_model;
            fargs = cell(1,length(obj.depend_on));
            % ---
            for i = 1:length(obj.depend_on)
                depon_ = obj.depend_on{i};
                % ---
                if isa(depon_,'Parameter')
                    fargs{i} = depon_.getvalue;
                elseif any(f_strcmpi(depon_,{'celem','cface','cedge','velem','sface','ledge'}))
                    % take from parameter parent_model's mesh
                    fargs{i} = target_model.parent_mesh.(depon_)(:,id_place_target);
                elseif any(f_strcmpi(depon_,{'ltime','time'}))
                    % take from parent_model of parameter object
                    fargs{i} = target_model.ltime.t_now;
                elseif any(f_strcmpi(depon_,{'fr'}))
                    % take from parent_model of parameter object
                    fargs{i} = target_model.fr;
                elseif any(f_strcmpi(depon_,{'V','I','Z'}))
                    fargs{i} = obj.get_coil_quantity(obj.from{i},depon_,obj.id_coil{i});
                elseif any(f_strcmpi(depon_,{'J','T','B','E','H','A','P','Phi'}))
                    fargs{i} = obj.get_field_quantity(obj.from{i},depon_,obj.dit{i},...
                                   target_dom,place,id_place_target,dependency_search);
                end
            end
        end
        %------------------------------------------------------------------
        function fargs = get_fargs_free(obj)
            % free defined parameter (no parent model)
            fargs = cell(1,length(obj.depend_on));
            for i = 1:length(obj.depend_on)
                if isa(obj.depend_on{i},'Parameter')
                    fargs{i} = obj.depend_on{i}.getvalue;
                else
                    % --- XTODO : need more generic
                    pvalue__ = obj.from{i}.(obj.depend_on{i});
                    if isa(pvalue__,'Parameter')
                        fargs{i} = pvalue__.getvalue;
                    elseif isa(pvalue__,'LTime')
                        fargs{i} = pvalue__.t_now;
                    elseif isnumeric(pvalue__)
                        fargs{i} = pvalue__;
                    else
                        error('Cannot evaluate parameter value !');
                    end
                end
            end
        end
        %------------------------------------------------------------------
        function val = get_coil_quantity(obj,source_model,quantity,id_coil_)
            % circuit quantity (V,I,Z) of a coil of the source model,
            % interpolated at the target model actual time
            if ~isprop(source_model,'coil')
                error('no coil in source model !');
            elseif ~isfield(source_model.coil,id_coil_)
                error(['no #coil ' id_coil_ ' in source model !'])
            end
            % --- get by time interpolation
            t_now = obj.parent_model.ltime.t_now;
            next_it = source_model.ltime.next_it(t_now);
            back_it = source_model.ltime.back_it(t_now);
            % ---
            val = source_model.coil.(id_coil_).(quantity){back_it};
            if next_it ~= back_it
                val = Parameter.lerp(val,...
                          source_model.coil.(id_coil_).(quantity){next_it},...
                          source_model.ltime.t_array(back_it),...
                          source_model.ltime.t_array(next_it),t_now);
            end
        end
        %------------------------------------------------------------------
        function val = get_field_quantity(obj,source_model,quantity,dit_,...
                           target_dom,place,id_place_target,dependency_search)
            % physical quantity (J,T,B,...) of the source model, brought to
            % the target support ; must be able to take from another model
            % with different ltime, mesh/dom
            target_model = obj.parent_model;
            % --- target time step, clamped to [1,it_max] (dit_ <= 0)
            target_it = target_model.ltime.it + dit_;
            target_it = min(target_model.ltime.it_max,max(1,target_it));
            target_t = target_model.ltime.t_at(target_it);
            % --- same model : direct read, no interpolation
            if isequal(source_model,target_model)
                val = source_model.field{target_it}.(quantity).(place).cvalue(id_place_target);
                return
            end
            % --- same mesh, no relative motion : read on same support,
            %     with time interpolation if ltime differ
            if isequal(source_model.parent_mesh,target_model.parent_mesh) && ...
               Parameter.frames_compatible(source_model,target_model)
                val = Parameter.read_same_mesh(source_model,target_model,...
                          quantity,place,id_place_target,target_it,target_t);
                return
            end
            % --- different mesh and/or relative motion :
            %     time interpolation then space interpolation
            if f_strcmpi(place,'elem')
                val = Parameter.read_cross_mesh_elem(source_model,target_model,...
                          quantity,target_dom,id_place_target,dependency_search,target_t);
            elseif f_strcmpi(place,'face')
                val = Parameter.read_cross_mesh_face(source_model,target_model,...
                          quantity,target_dom,id_place_target,dependency_search,target_t);
            else
                val = [];
            end
        end
    end

    %----------------------------------------------------------------------
    % --- helpers
    methods (Static, Access = private)
        %------------------------------------------------------------------
        function fh = const_to_fhandle(const)
            % wrap a numeric constant into a 0-argument function handle
            sizeconst = size(const);
            % ---
            if numel(const) == 1 || isempty(const)
                fh = @()(const);
            elseif numel(const) == 2 || numel(const) == 3
                const = f_tocolv(const);
                fh = @()(const);
            elseif isequal(sizeconst,[2 2]) || isequal(sizeconst,[3 3])
                fh = @()(const);
            else
                fprintf(['Constant parameter must be a single scalar, ' ...
                         'single vector or single tensor !\n' ...
                         'Consider ScalarParameter, VectorParameter or TensorParameter ' ...
                         'for general purpose. \n']);
                error('constant parameter error');
            end
        end
        %------------------------------------------------------------------
        function [depend_on_,dit_,id_coil_] = parse_dependencies(depon)
            % parse dependency tokens :
            % 'celem','B','B(-1)','V.id_coil','V(-1).id_coil','ltime',...
            % or Parameter objects (kept as is)
            len_depon  = length(depon);
            depend_on_ = cell(1,len_depon);
            dit_       = cell(1,len_depon);
            id_coil_   = cell(1,len_depon);
            % ---
            for i = 1:len_depon
                if isa(depon{i},'Parameter')
                    depend_on_{i} = depon{i};
                elseif ischar(depon{i}) || isstring(depon{i})
                    str00 = split(depon{i},'.');
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
                    % ---
                    if dit_{i} > 0
                        error('Cannot defined dependency on next time step !');
                    end
                else
                    error('#depend_on must be char or Parameter');
                end
            end
        end
        %------------------------------------------------------------------
        function tf = is_all_parameter(depon)
            % true if all dependencies are Parameter objects (free parameters)
            tf = true;
            for i = 1:length(depon)
                if ~isa(depon{i},'Parameter')
                    tf = false;
                    return
                end
            end
        end
        %------------------------------------------------------------------
        function tf = varargs_isempty(varargs)
            if iscell(varargs)
                tf = isempty(varargs) || isempty(varargs{1});
            else
                tf = isempty(varargs);
            end
        end
        %------------------------------------------------------------------
        function a = slice_fargs(fargs,arg_subs,elem_dim,id_elem,nb_fargin)
            % extract the id_elem-th slice of each argument
            a = cell(1,nb_fargin);
            for i = 1:nb_fargin
                subs = arg_subs{i};
                if elem_dim(i) > 0
                    subs{elem_dim(i)} = id_elem;
                end
                a{i} = fargs{i}(subs{:});
            end
        end
        %------------------------------------------------------------------
        function [meshdom,place,id_place_target,dependency_search] = resolve_target(dom)
            % identify the mesh support (elem/face) described by #dom
            meshdom = [];
            place = [];
            id_place_target = [];
            dependency_search = [];
            % ---
            if isempty(dom)
                return
            end
            % ---
            if isa(dom,'PhysicalDom')
                meshdom = dom.dom;
                dependency_search = dom.parameter_dependency_search;
            else
                meshdom = dom;
            end
            % ---
            if isempty(dependency_search)
                dependency_search = 'by_coordinates';
            end
            % ---
            if isa(meshdom,'VolumeDom')
                place = 'elem';
                id_place_target = meshdom.gindex;
            elseif isa(meshdom,'SurfaceDom')
                place = 'face';
                id_place_target = meshdom.gindex;
            else
                error('must give #dom with .gindex !');
            end
        end
        %------------------------------------------------------------------
        function tf = frames_compatible(source_model,target_model)
            % true when source data can be read without space interpolation
            tf = (isa(source_model.moving_frame,'NotMovingFrame')  && ...
                  isa(target_model.moving_frame,'NotMovingFrame'))  || ...
                 (isa(source_model,'EmModel')  && ...
                  isa(target_model,'ThModel'));
        end
        %------------------------------------------------------------------
        function val = lerp(val01,val02,t01,t02,t)
            % linear time interpolation, numeric arrays or cell of arrays
            if iscell(val01)
                val = cell(size(val01));
                for k = 1:length(val01)
                    val{k} = val01{k} + (val02{k} - val01{k}) ./ (t02 - t01) .* (t - t01);
                end
            else
                val = val01 + (val02 - val01) ./ (t02 - t01) .* (t - t01);
            end
        end
        %------------------------------------------------------------------
        function val = read_same_mesh(source_model,target_model,quantity,...
                           place,id_target,target_it,target_t)
            % read cvalue on the shared support, time-interpolated if the
            % two models do not share the same time discretization
            src_max_it = length(source_model.field);
            % ---
            if isequal(source_model.ltime.t_array,target_model.ltime.t_array)
                % no interpolation
                it = min(target_it,src_max_it);
                val = source_model.field{it}.(quantity).(place).cvalue(id_target);
                return
            end
            % --- get by time interpolation
            next_it = min(source_model.ltime.next_it(target_t),src_max_it);
            back_it = min(source_model.ltime.back_it(target_t),src_max_it);
            % ---
            val = source_model.field{back_it}.(quantity).(place).cvalue(id_target);
            if next_it ~= back_it
                val = Parameter.lerp(val,...
                          source_model.field{next_it}.(quantity).(place).cvalue(id_target),...
                          source_model.ltime.t_array(back_it),...
                          source_model.ltime.t_array(next_it),target_t);
            end
        end
        %------------------------------------------------------------------
        function valcell = time_interp_ivalue(source_model,quantity,support,...
                               id_source,target_t)
            % ivalue on source interpolation points, time-interpolated
            src_max_it = length(source_model.field);
            next_it = min(source_model.ltime.next_it(target_t),src_max_it);
            back_it = min(source_model.ltime.back_it(target_t),src_max_it);
            % ---
            valcell = source_model.field{back_it}.(quantity).(support).ivalue(id_source);
            if next_it ~= back_it
                valcell = Parameter.lerp(valcell,...
                              source_model.field{next_it}.(quantity).(support).ivalue(id_source),...
                              source_model.ltime.t_array(back_it),...
                              source_model.ltime.t_array(next_it),target_t);
            end
        end
        %------------------------------------------------------------------
        function id_elem_source = find_source_elems(source_model,target_model,...
                                      target_dom,id_elem_target,dependency_search,target_t)
            % source elements carrying the data : by dom id when possible,
            % otherwise by coordinates
            id_elem_source = [];
            % ---
            if f_strcmpi(dependency_search,'by_id_dom') && ...
               Parameter.frames_compatible(source_model,target_model)
                id_elem_source = Parameter.find_dom_gindex(source_model,target_dom.id);
                if isempty(id_elem_source)
                    if isa(source_model,'EmModel') && isa(target_model,'ThModel')
                        f_fprintf(1,'/!\\',0,'volumedom',1,target_dom.id,0,'not found on source model !');
                        error('VolumeDom not found on source model');
                    end
                    f_fprintf(0,'volumedom',1,target_dom.id,0,'not found on source model !',...
                        0,'champ3d performs #parameter_dependency_search by_coordinates \n');
                end
            end
            % ---
            if isempty(id_elem_source)
                id_elem_source = f_findelem(source_model.moving_frame.node(target_t),...
                                     source_model.parent_mesh.elem,...
                                     'in_box',target_model.moving_frame.localbox(id_elem_target,target_t));
            end
        end
        %------------------------------------------------------------------
        function [id_face_source,id_elem_source] = find_source_faces(...
                     source_model,target_model,target_dom,dependency_search,target_t)
            % source faces carrying the data : by dom id when possible,
            % otherwise fall back on source elements found by coordinates
            id_face_source = [];
            id_elem_source = [];
            % ---
            if f_strcmpi(dependency_search,'by_id_dom') && ...
               Parameter.frames_compatible(source_model,target_model)
                id_face_source = Parameter.find_dom_gindex(source_model,target_dom.id);
                if isempty(id_face_source)
                    if isa(source_model,'EmModel') && isa(target_model,'ThModel')
                        f_fprintf(1,'/!\\',0,'surfacedom',1,target_dom.id,0,'not found on source model !');
                        error('Surfacedom not found on source model');
                    end
                    f_fprintf(0,'surfacedom',1,target_dom.id,0,'not found on source model !',...
                        0,'champ3d performs #parameter_dependency_search by_coordinates \n');
                end
            end
            % ---
            if isempty(id_face_source)
                % --- XTODO add log message
                id_elem_source = f_findelem(source_model.moving_frame.node(target_t),...
                                     source_model.parent_mesh.elem,...
                                     'in_box',target_model.moving_frame.localbox([],target_t));
            end
        end
        %------------------------------------------------------------------
        function gindex = find_dom_gindex(source_model,id_dom)
            % gindex of the source mesh dom whose id matches id_dom
            gindex = [];
            id_dom_source = fieldnames(source_model.parent_mesh.dom);
            for ids = 1:length(id_dom_source)
                if f_strcmpi(id_dom_source{ids},id_dom)
                    gindex = source_model.parent_mesh.dom.(id_dom_source{ids}).gindex;
                end
            end
        end
        %------------------------------------------------------------------
        function node_i = stack_nodes(interp_node,id_entity)
            % stack interpolation-point coordinates : (nbINode*nb_entity) x 3
            % id_entity = [] when interp_node cells are already sliced
            nbINode = length(interp_node);
            if isempty(id_entity)
                nb_entity = size(interp_node{1},1);
            else
                nb_entity = length(id_entity);
            end
            % ---
            node_i = zeros(nbINode * nb_entity,3);
            id0 = 1:nb_entity;
            for k = 1:nbINode
                idn = id0 + (k - 1) * nb_entity;
                if isempty(id_entity)
                    node_i(idn,:) = interp_node{k};
                else
                    node_i(idn,:) = interp_node{k}(id_entity,:);
                end
            end
        end
        %------------------------------------------------------------------
        function q = to_source_frame(target_model,source_model,coords,target_t)
            % express target support coordinates (3 x n) in the source
            % moving frame ; returns query points (n x 3)
            q = target_model.moving_frame.movenode(coords,target_t);
            q = source_model.moving_frame.inverse_movenode(q,target_t);
            q = q.';
        end
        %------------------------------------------------------------------
        function val = space_interp(node_i,valcell,query_points)
            % scattered linear interpolation, component per component
            % node_i       : (nbINode*nb_entity) x 3 stacked coordinates
            % valcell      : cell {nbINode}, each nb_entity x dim
            % query_points : nq x 3
            nbINode = length(valcell);
            nb_entity = size(valcell{1},1);
            dim_ = size(valcell{1},2);
            % ---
            val = zeros(size(query_points,1),dim_);
            id0 = 1:nb_entity;
            fxi = [];
            for d = 1:dim_
                % --- stack the d-th component on all interpolation points
                vald = zeros(nbINode * nb_entity,1);
                for k = 1:nbINode
                    idn = id0 + (k - 1) * nb_entity;
                    vald(idn) = valcell{k}(:,d);
                end
                % --- triangulation built once, values swapped per component
                if d == 1
                    fxi = scatteredInterpolant(node_i,vald,'linear','none');
                else
                    fxi.Values = vald;
                end
                % ---
                vd = fxi(query_points);
                vd(isnan(vd)) = 0;
                val(:,d) = vd;
            end
        end
        %------------------------------------------------------------------
        function val = read_cross_mesh_elem(source_model,target_model,quantity,...
                           target_dom,id_elem_target,dependency_search,target_t)
            % time then space interpolation onto target element centers
            id_elem_source = Parameter.find_source_elems(source_model,target_model,...
                                 target_dom,id_elem_target,dependency_search,target_t);
            % --- time interpolated data
            valcell = Parameter.time_interp_ivalue(source_model,quantity,'elem',...
                          id_elem_source,target_t);
            % --- space interpolation
            node_i = Parameter.stack_nodes(source_model.parent_mesh.prokit.node,id_elem_source);
            q = Parameter.to_source_frame(target_model,source_model,...
                    target_model.parent_mesh.celem(:,id_elem_target),target_t);
            val = Parameter.space_interp(node_i,valcell,q);
            % ---
            if size(val,2) > 1
                val = source_model.moving_frame.movevector(val,target_t);
            end
        end
        %------------------------------------------------------------------
        function val = read_cross_mesh_face(source_model,target_model,quantity,...
                           target_dom,id_face_target,dependency_search,target_t)
            % time then space interpolation onto target face centers
            [id_face_source,id_elem_source] = Parameter.find_source_faces(...
                source_model,target_model,target_dom,dependency_search,target_t);
            % ---
            if ~isempty(id_face_source)
                % --- time interpolated data
                valcell = Parameter.time_interp_ivalue(source_model,quantity,'face',...
                              id_face_source,target_t);
                % --- take interp_node from Field (already sliced)
                back_it = min(source_model.ltime.back_it(target_t),length(source_model.field));
                interp_node = source_model.field{back_it}.(quantity).face.inode(id_face_source);
                node_i = Parameter.stack_nodes(interp_node,[]);
            elseif ~isempty(id_elem_source)
                % --- XTODO : not optimal code writing/organization
                valcell = Parameter.time_interp_ivalue(source_model,quantity,'elem',...
                              id_elem_source,target_t);
                node_i = Parameter.stack_nodes(source_model.parent_mesh.prokit.node,id_elem_source);
            else
                val = 0;
                return
            end
            % --- space interpolation
            q = Parameter.to_source_frame(target_model,source_model,...
                    target_model.parent_mesh.cface(:,id_face_target),target_t);
            val = Parameter.space_interp(node_i,valcell,q);
            % ---
            if size(val,2) > 1
                val = source_model.moving_frame.movevector(val,target_t);
            end
        end
        %------------------------------------------------------------------
    end
end
