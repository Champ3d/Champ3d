%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Parameter < Xhandle
    properties
        f
        depend_on
        from
        varargin_list
        fvectorized
        % ---
    end

    % --- Contructor
    methods
        function obj = Parameter(args)
            arguments
                args.f = []
                args.depend_on {mustBeMember(args.depend_on,...
                    {'celem','cface', ...
                     'bv','jv','hv','pv','av','phiv','tv','omev','tempv',...
                     'bs','js','hs','ps','as','phis','ts','omes','temps'})} = 'celem'
                args.from = []
                args.varargin_list = []
                args.fvectorized = 0
            end
            % ---
            if isempty(args.f)
                error('#f must be given ! Give a function handle or numeric value');
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
        function vout = evaluate_on(obj,dom)
            if obj.fvectorized
                vout = eval_fvectorized(obj,dom);
                vout = obj.column_format(vout);
            else
                vout = eval_fserial(obj,dom);
                vout = obj.column_format(vout);
            end
        end
        %------------------------------------------------------------------
        function vout = eval_fvectorized(obj,dom)
            %--------------------------------------------------------------
            f_ = obj.f;
            nb_fargin = f_nargin(obj.f);
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
                    poidelem(i) = po;
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
            end
            % ---
            fargs = cell(1,length(obj.depend_on));
            % ---
            depon__ = obj.depend_on;
            from__  = obj.from;
            for i = 1:length(depon__)
                depon_ = depon__{i};
                from_  = from__{i};
                if any(f_strcmpi(depon_,{'celem','cface'}))
                    fargs{i} = from_.parent_mesh.(depon_)(:,id_elem);
                elseif any(f_strcmpi(depon_,{...
                        'bv','jv','hv','pv','av','phiv','tv','omev','tempv',...
                        'bs','js','hs','ps','as','phis','ts','omes','temps'}))
                    fargs{i} = from_.fields.(depon_)(:,id_elem);
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
                end
            end
        end
        %------------------------------------------------------------------

    end
end