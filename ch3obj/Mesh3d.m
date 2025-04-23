%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh3d < Mesh

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Constructors
    methods
        function obj = Mesh3d()
            obj = obj@Mesh;
            % ---
            Mesh3d.setup(obj);
            % ---
        end
    end
    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@Mesh(obj);
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % reset super
            reset@Mesh(obj);
            % ---
            obj.setup_done = 0;
            Mesh3d.setup(obj);
            % --- reset dependent obj
            % obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            Mesh3d.setup(obj);
            % --- call super
            build@Mesh(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end

    % --- Methods - Add dom
    methods
        % ---
        function add_vdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
                % ---
                args.id_dom3d = [];
                args.cut_equation = [];
            end
            % ---
            args.parent_mesh = obj;
            % ---
            if isempty(args.id_dom3d) && isempty(args.cut_equation)
                argu = f_to_namedarg(args,'for','VolumeDom3d');
                dom = VolumeDom3d(argu{:});
            else
                argu = f_to_namedarg(args,'for','CutVolumeDom3d');
                dom = CutVolumeDom3d(argu{:});
            end
            obj.dom.(args.id) = dom;
            % ---
            obj.is_defining_obj_of(dom);
            % ---
        end
        % -----------------------------------------------------------------
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.defined_on char = []
                args.id_dom3d = []
                % ---
                args.elem_code = []
                args.gid_face = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'for','SurfaceDom3d');
            dom = SurfaceDom3d(argu{:});
            obj.dom.(args.id) = dom;
            % ---
            % obj.is_defining_obj_of(dom);
            % ---
        end
    end
    
    % --- Methods - Integ
    methods
        % -----------------------------------------------------------------
        function coefwn = cwn(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbNo_inEl = refelem.nbNo_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.Wn) || isempty(obj.intkit.cWn)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    Wn = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wn{iG} = obj.intkit.cWn{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    Wn = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wn{iG} = obj.intkit.Wn{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwn = zeros(nb_elem,nbNo_inEl);
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbNo_inEl
                        wix = Wn{iG}(:,i);
                        coefwn(:,i) = coefwn(:,i) + ...
                            weigh .* dJ .* coefficient .* wix;
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwnwn = cwnwn(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbNo_inEl = refelem.nbNo_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.Wn) || isempty(obj.intkit.cWn)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    Wn = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wn{iG} = obj.intkit.cWn{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    Wn = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wn{iG} = obj.intkit.Wn{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwnwn = zeros(nb_elem,nbNo_inEl,nbNo_inEl);
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbNo_inEl
                        wix = Wn{iG}(:,i);
                        for j = i:nbNo_inEl
                            wjx = Wn{iG}(:,j);
                            coefwnwn(:,i,j) = coefwnwn(:,i,j) + ...
                                weigh .* dJ .* coefficient .* wix .* wjx;
                        end
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwewe = cwewe(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbEd_inEl = refelem.nbEd_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.We) || isempty(obj.intkit.cWe)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    We = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    We = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.We{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwewe = zeros(nb_elem,nbEd_inEl,nbEd_inEl);
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        wiz = We{iG}(:,3,i);
                        for j = i:nbEd_inEl % !!! i
                            wjx = We{iG}(:,1,j);
                            wjy = We{iG}(:,2,j);
                            wjz = We{iG}(:,3,j);
                            % ---
                            coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                (wix .* wjx + wiy .* wjy + wiz .* wjz) );
                        end
                    end
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        wiz = We{iG}(:,3,i);
                        for j = i:nbEd_inEl % !!! i
                            wjx = We{iG}(:,1,j);
                            wjy = We{iG}(:,2,j);
                            wjz = We{iG}(:,3,j);
                            % ---
                            coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* wix .* wjx +...
                                coefficient(:,1,2) .* wiy .* wjx +...
                                coefficient(:,1,3) .* wiz .* wjx +...
                                coefficient(:,2,1) .* wix .* wjy +...
                                coefficient(:,2,2) .* wiy .* wjy +...
                                coefficient(:,2,3) .* wiz .* wjy +...
                                coefficient(:,3,1) .* wix .* wjz +...
                                coefficient(:,3,2) .* wiy .* wjz +...
                                coefficient(:,3,3) .* wiz .* wjz );
                        end
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwewf = cwewf(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbEd_inEl = refelem.nbEd_inEl;
            nbFa_inEl = refelem.nbFa_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.We) || isempty(obj.intkit.cWe) || ...
                    isempty(obj.intkit.Wf) || isempty(obj.intkit.cWf)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    We = cell(1,nbG);
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                        Wf{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    We = cell(1,nbG);
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.We{iG}(id_elem,:,:);
                        Wf{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwewf = zeros(nb_elem,nbEd_inEl,nbFa_inEl);
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbEd_inEl
                        weix = We{iG}(:,1,i);
                        weiy = We{iG}(:,2,i);
                        weiz = We{iG}(:,3,i);
                        for j = 1:nbFa_inEl % !!! 1
                            wfjx = Wf{iG}(:,1,j);
                            wfjy = Wf{iG}(:,2,j);
                            wfjz = Wf{iG}(:,3,j);
                            % ---
                            coefwewf(:,i,j) = coefwewf(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                (weix .* wfjx + weiy .* wfjy + weiz .* wfjz) );
                        end
                    end
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbEd_inEl
                        weix = We{iG}(:,1,i);
                        weiy = We{iG}(:,2,i);
                        weiz = We{iG}(:,3,i);
                        for j = 1:nbFa_inEl % !!! 1
                            wfjx = Wf{iG}(:,1,j);
                            wfjy = Wf{iG}(:,2,j);
                            wfjz = Wf{iG}(:,3,j);
                            % ---
                            coefwewf(:,i,j) = coefwewf(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* weix .* wfjx +...
                                coefficient(:,1,2) .* weiy .* wfjx +...
                                coefficient(:,1,3) .* weiz .* wfjx +...
                                coefficient(:,2,1) .* weix .* wfjy +...
                                coefficient(:,2,2) .* weiy .* wfjy +...
                                coefficient(:,2,3) .* weiz .* wfjy +...
                                coefficient(:,3,1) .* weix .* wfjz +...
                                coefficient(:,3,2) .* weiy .* wfjz +...
                                coefficient(:,3,3) .* weiz .* wfjz );
                        end
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwfwf = cwfwf(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbFa_inEl = refelem.nbFa_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.Wf) || isempty(obj.intkit.cWf)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wf{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wf{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwfwf = zeros(nb_elem,nbFa_inEl,nbFa_inEl);
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbFa_inEl
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        wiz = Wf{iG}(:,3,i);
                        for j = i:nbFa_inEl % !!! i
                            wjx = Wf{iG}(:,1,j);
                            wjy = Wf{iG}(:,2,j);
                            wjz = Wf{iG}(:,3,j);
                            % ---
                            coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                (wix .* wjx + wiy .* wjy + wiz .* wjz) );
                        end
                    end
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    for i = 1:nbFa_inEl
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        wiz = Wf{iG}(:,3,i);
                        for j = i:nbFa_inEl % !!! i
                            wjx = Wf{iG}(:,1,j);
                            wjy = Wf{iG}(:,2,j);
                            wjz = Wf{iG}(:,3,j);
                            % ---
                            coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* wix .* wjx +...
                                coefficient(:,1,2) .* wiy .* wjx +...
                                coefficient(:,1,3) .* wiz .* wjx +...
                                coefficient(:,2,1) .* wix .* wjy +...
                                coefficient(:,2,2) .* wiy .* wjy +...
                                coefficient(:,2,3) .* wiz .* wjy +...
                                coefficient(:,3,1) .* wix .* wjz +...
                                coefficient(:,3,2) .* wiy .* wjz +...
                                coefficient(:,3,3) .* wiz .* wjz );
                        end
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwevf = cwevf(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.vector_field = [1 1 1];
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            vector_field = args.vector_field;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            if ~iscell(vector_field)
                vector_field = f_column_format(vector_field);
            end
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbEd_inEl = refelem.nbEd_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.We) || isempty(obj.intkit.cWe)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    We = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    We = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        We{iG} = obj.intkit.We{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwevf = zeros(nb_elem,nbEd_inEl);
            %--------------------------------------------------------------
            vfx = cell(3,1);
            vfy = cell(3,1);
            vfz = cell(3,1);
            if ~iscell(vector_field)
                for iG = 1:nbG
                    if numel(vector_field) == 3
                        vfx{iG} = vector_field(1);
                        vfy{iG} = vector_field(2);
                        vfz{iG} = vector_field(3);
                    elseif size(vector_field,1) >  length(id_elem) && ...
                            size(vector_field,1) == obj.nb_elem
                        vfx{iG} = vector_field(id_elem,1);
                        vfy{iG} = vector_field(id_elem,2);
                        vfz{iG} = vector_field(id_elem,3);
                    else
                        vfx{iG} = vector_field(:,1);
                        vfy{iG} = vector_field(:,2);
                        vfz{iG} = vector_field(:,3);
                    end
                end
            else
                for iG = 1:nbG
                    vfx{iG} = vector_field{iG}(:,1);
                    vfy{iG} = vector_field{iG}(:,2);
                    vfz{iG} = vector_field{iG}(:,3);
                end
            end
            %--------------------------------------------------------------
            if any(strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    % ---
                    vix = vfx{iG}(:,1);
                    viy = vfy{iG}(:,1);
                    viz = vfz{iG}(:,1);
                    % ---
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        wiz = We{iG}(:,3,i);
                        coefwevf(:,i) = coefwevf(:,i) + ...
                            weigh .* dJ .* ( coefficient .* ...
                            (wix .* vix + wiy .* viy + wiz .* viz) );
                    end
                end
                %----------------------------------------------------------
            elseif any(strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    % ---
                    vix = vfx{iG}(:,1);
                    viy = vfy{iG}(:,1);
                    viz = vfz{iG}(:,1);
                    % ---
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        wiz = We{iG}(:,3,i);
                        coefwevf(:,i) = coefwevf(:,i) + ...
                            weigh .* dJ .* (...
                            coefficient(:,1,1) .* wix .* vix +...
                            coefficient(:,1,2) .* wiy .* vix +...
                            coefficient(:,1,3) .* wiz .* vix +...
                            coefficient(:,2,1) .* wix .* viy +...
                            coefficient(:,2,2) .* wiy .* viy +...
                            coefficient(:,2,3) .* wiz .* viy +...
                            coefficient(:,3,1) .* wix .* viz +...
                            coefficient(:,3,2) .* wiy .* viz +...
                            coefficient(:,3,3) .* wiz .* viz );
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function coefwfvf = cwfvf(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.vector_field = [1 1 1];
                args.order = 'full'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            order = args.order;
            vector_field = args.vector_field;
            %--------------------------------------------------------------
            if isempty(id_elem)
                nb_elem = obj.nb_elem;
                id_elem = 1:nb_elem;
            else
                nb_elem = length(id_elem);
            end
            % ---
            if isnumeric(order)
                if order < 1
                    order = '0';
                else
                    order = 'full';
                end
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            %--------------------------------------------------------------
            if ~iscell(vector_field)
                vector_field = f_column_format(vector_field);
            end
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbFa_inEl = refelem.nbFa_inEl;
            %--------------------------------------------------------------
            if isempty(obj.intkit.Wf) || isempty(obj.intkit.cWf)
                obj.build_intkit;
            end
            %--------------------------------------------------------------
            switch order
                case '0'
                    nbG = 1;
                    Weigh = refelem.cWeigh;
                    % ---
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wf{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.cdetJ{iG}(id_elem,1);
                    end
                case 'full'
                    nbG = refelem.nbG;
                    Weigh = refelem.Weigh;
                    % ---
                    Wf = cell(1,nbG);
                    detJ = cell(1,nbG);
                    for iG = 1:nbG
                        Wf{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
                        detJ{iG} = obj.intkit.detJ{iG}(id_elem,1);
                    end
            end
            %--------------------------------------------------------------
            coefwfvf = zeros(nb_elem,nbFa_inEl);
            %--------------------------------------------------------------
            vfx = cell(3,1);
            vfy = cell(3,1);
            vfz = cell(3,1);
            if ~iscell(vector_field)
                for iG = 1:nbG
                    if numel(vector_field) == 3
                        vfx{iG} = vector_field(1);
                        vfy{iG} = vector_field(2);
                        vfz{iG} = vector_field(3);
                    elseif size(vector_field,1) >  length(id_elem) && ...
                            size(vector_field,1) == obj.nb_elem
                        vfx{iG} = vector_field(id_elem,1);
                        vfy{iG} = vector_field(id_elem,2);
                        vfz{iG} = vector_field(id_elem,3);
                    else
                        vfx{iG} = vector_field(:,1);
                        vfy{iG} = vector_field(:,2);
                        vfz{iG} = vector_field(:,3);
                    end
                end
            else
                for iG = 1:nbG
                    vfx{iG} = vector_field{iG}(:,1);
                    vfy{iG} = vector_field{iG}(:,2);
                    vfz{iG} = vector_field{iG}(:,3);
                end
            end
            %--------------------------------------------------------------
            if any(strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    % ---
                    vix = vfx{iG}(:,1);
                    viy = vfy{iG}(:,1);
                    viz = vfz{iG}(:,1);
                    % ---
                    for i = 1:nbFa_inEl
                        % ---
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        wiz = Wf{iG}(:,3,i);
                        % ---
                        coefwfvf(:,i) = coefwfvf(:,i) + ...
                            weigh .* dJ .* ( coefficient .* ...
                            (wix .* vix + wiy .* viy + wiz .* viz) );
                    end
                end
                %----------------------------------------------------------
            elseif any(strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    dJ    = f_tocolv(detJ{iG});
                    weigh = Weigh(iG);
                    % ---
                    vix = vfx{iG}(:,1);
                    viy = vfy{iG}(:,1);
                    viz = vfz{iG}(:,1);
                    % ---
                    for i = 1:nbFa_inEl
                        % ---
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        wiz = Wf{iG}(:,3,i);
                        % ---
                        coefwfvf(:,i) = coefwfvf(:,i) + ...
                            weigh .* dJ .* (...
                            coefficient(:,1,1) .* wix .* vix +...
                            coefficient(:,1,2) .* wiy .* vix +...
                            coefficient(:,1,3) .* wiz .* vix +...
                            coefficient(:,2,1) .* wix .* viy +...
                            coefficient(:,2,2) .* wiy .* viy +...
                            coefficient(:,2,3) .* wiz .* viy +...
                            coefficient(:,3,1) .* wix .* viz +...
                            coefficient(:,3,2) .* wiy .* viz +...
                            coefficient(:,3,3) .* wiz .* viz );
                    end
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods - Get field
    methods
        % -----------------------------------------------------------------
        function scalar_field = field_wn(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.dof = 1
                args.on {mustBeMember(args.on,{'center','gauss_points','interpolation_points'})} = 'center'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            dof = args.dof;
            on_ = args.on;
            %--------------------------------------------------------------
            nb_elem = obj.nb_elem;
            % ---
            if isempty(id_elem)
                id_elem = 1:nb_elem;
            end
            %--------------------------------------------------------------
            if numel(dof) ~= obj.nb_node
                error('dof must be defined in whole mesh !');
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            dof = f_column_format(dof);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbNo_inEl = refelem.nbNo_inEl;
            %--------------------------------------------------------------
            if isempty(obj.elem)
                error('No mesh data !');
            end
            elem = obj.elem;
            %--------------------------------------------------------------
            switch on_
                case 'center'
                    % ---
                    if isempty(obj.intkit.cWn)
                        obj.build_intkit;
                    end
                    % ---
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWn{iG}(id_elem,:);
                    end
                case 'gauss_points'
                    % ---
                    if isempty(obj.intkit.Wn)
                        obj.build_intkit;
                    end
                    % ---
                    nbG = refelem.nbG;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.Wn{iG}(id_elem,:);
                    end
                case 'interpolation_points'
                    % ---
                    if isempty(obj.prokit.Wn)
                        obj.build_prokit;
                    end
                    % ---
                    nbG = obj.refelem.nbI;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.prokit.Wn{iG}(id_elem,:);
                    end
            end
            %--------------------------------------------------------------
            scalar_field = cell(nbG,1);
            for i = 1:nbG
                scalar_field{i} = sparse(1,nb_elem);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),1);
                    for i = 1:nbNo_inEl
                        wi = Wx{iG}(:,i);
                        id_node = elem(i,id_elem);
                        fi(:,1) = fi(:,1) + coefficient .* wi .* dof(id_node);
                    end
                    % ---
                    scalar_field{iG}(1,id_elem) = fi.';
                end
                % ---
                if nbG == 1
                    scalar_field = scalar_field{1};
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function vector_field = field_we(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.dof = 1
                args.on {mustBeMember(args.on,{'center','gauss_points','interpolation_points'})} = 'center'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            dof = args.dof;
            on_ = args.on;
            %--------------------------------------------------------------
            nb_elem = obj.nb_elem;
            % ---
            if isempty(id_elem)
                id_elem = 1:nb_elem;
            end
            %--------------------------------------------------------------
            if numel(dof) ~= obj.nb_edge
                error('dof must be defined in whole mesh !');
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            dof = f_column_format(dof);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbEd_inEl = refelem.nbEd_inEl;
            %--------------------------------------------------------------
            if isempty(obj.meshds.id_edge_in_elem)
                obj.build_meshds;
            end
            id_edge_in_elem = obj.meshds.id_edge_in_elem;
            %--------------------------------------------------------------
            switch on_
                case 'center'
                    % ---
                    if isempty(obj.intkit.cWe)
                        obj.build_intkit;
                    end
                    % ---
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                    end
                case 'gauss_points'
                    % ---
                    if isempty(obj.intkit.We)
                        obj.build_intkit;
                    end
                    % ---
                    nbG = refelem.nbG;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.We{iG}(id_elem,:,:);
                    end
                case 'interpolation_points'
                    % ---
                    if isempty(obj.prokit.We)
                        obj.build_prokit;
                    end
                    % ---
                    nbG = obj.refelem.nbI;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.prokit.We{iG}(id_elem,:,:);
                    end
            end
            %--------------------------------------------------------------
            vector_field = cell(nbG,1);
            for i = 1:nbG
                vector_field{i} = sparse(3,nb_elem);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),3);
                    for i = 1:nbEd_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        wiz = Wx{iG}(:,3,i);
                        id_edge = id_edge_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + coefficient .* wix .* dof(id_edge);
                        fi(:,2) = fi(:,2) + coefficient .* wiy .* dof(id_edge);
                        fi(:,3) = fi(:,3) + coefficient .* wiz .* dof(id_edge);
                    end
                    % ---
                    vector_field{iG}(1:3,id_elem) = fi.';
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(3,length(id_elem));
                    %------------------------------------------------------
                    for i = 1:nbEd_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        wiz = Wx{iG}(:,3,i);
                        id_edge = id_edge_in_elem(i,id_elem);
                        fi(1,:) = fi(1,:) + (coefficient(:,1,1) .* wix + ...
                            coefficient(:,1,2) .* wiy + ...
                            coefficient(:,1,3) .* wiz) .* dof(id_edge) ;
                        fi(2,:) = fi(2,:) + (coefficient(:,2,1) .* wix + ...
                            coefficient(:,2,2) .* wiy + ...
                            coefficient(:,2,3) .* wiz) .* dof(id_edge) ;
                        fi(3,:) = fi(3,:) + (coefficient(:,3,1) .* wix + ...
                            coefficient(:,3,2) .* wiy + ...
                            coefficient(:,3,3) .* wiz) .* dof(id_edge) ;
                    end
                    % ---
                    vector_field{iG}(1:3,id_elem) = fi.';
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
        function vector_field = field_wf(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.dof = 1
                args.on {mustBeMember(args.on,{'center','gauss_points','interpolation_points'})} = 'center'
            end
            %--------------------------------------------------------------
            id_elem = args.id_elem;
            coefficient = args.coefficient;
            dof = args.dof;
            on_ = args.on;
            %--------------------------------------------------------------
            nb_elem = obj.nb_elem;
            % ---
            if isempty(id_elem)
                id_elem = 1:nb_elem;
            end
            %--------------------------------------------------------------
            if numel(dof) ~= obj.nb_face
                error('dof must be defined in whole mesh !');
            end
            %--------------------------------------------------------------
            [coefficient, coef_array_type] = f_column_format(coefficient);
            dof = f_column_format(dof);
            %--------------------------------------------------------------
            refelem = obj.refelem;
            nbFa_inEl = refelem.nbFa_inEl;
            %--------------------------------------------------------------
            if isempty(obj.meshds.id_face_in_elem)
                obj.build_meshds;
            end
            id_face_in_elem = obj.meshds.id_face_in_elem;
            %--------------------------------------------------------------
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
                    nbG = refelem.nbG;
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
            %--------------------------------------------------------------
            vector_field = cell(nbG,1);
            for i = 1:nbG
                vector_field{i} = sparse(3,nb_elem);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
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
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(3,length(id_elem));
                    %------------------------------------------------------
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
                %----------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------
    end
end




