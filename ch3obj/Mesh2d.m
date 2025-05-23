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

classdef Mesh2d < Mesh
    % --- Constructors
    methods
        function obj = Mesh2d()
            obj = obj@Mesh;
        end
    end
    % --- Methods - Add dom
    methods
        % ---
        function add_vdom(obj,args)
            arguments
                obj
                % ---
                args.id char = []
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gindex = []
                args.condition char = []
                % ---
                args.dom_obj {mustBeA(args.dom_obj,{'VolumeDom2d'})}
            end
            % ---
            if isempty(args.id)
                error('#id must be given !');
            end
            % ---
            if ~isfield(args,'dom_obj')
                args.parent_mesh = obj;
                % ---
                argu = f_to_namedarg(args,'for','VolumeDom2d');
                dom = VolumeDom2d(argu{:});
                obj.dom.(args.id) = dom;
                % ---
                obj.is_defining_obj_of(dom);
                % ---
            else
                dom = args.dom_obj;
                dom.id = args.id;
                obj.dom.(args.id) = dom;
                % obj.is_defining_obj_of(dom);
            end
        end
        % --- XTODO
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d = []
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gindex = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'for','SurfaceDom2d');
            dom = SurfaceDom2d(argu{:});
            obj.dom.(args.id) = dom;
            % ---
            obj.is_defining_obj_of(dom);
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
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
                        weix = We{iG}(:,1,i);
                        weiy = We{iG}(:,2,i);
                        for j = i:nbEd_inEl % !!! i
                            wejx = We{iG}(:,1,j);
                            wejy = We{iG}(:,2,j);
                            % ---
                            coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                (weix .* wejx + weiy .* wejy) );
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
                        for j = i:nbEd_inEl % !!! i
                            wejx = We{iG}(:,1,j);
                            wejy = We{iG}(:,2,j);
                            % ---
                            coefwewe(:,i,j) = coefwewe(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* weix .* wejx +...
                                coefficient(:,1,2) .* weiy .* wejx +...
                                coefficient(:,2,1) .* weix .* wejy +...
                                coefficient(:,2,2) .* weiy .* wejy );
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
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
                        weix = Wf{iG}(:,1,i);
                        weiy = Wf{iG}(:,2,i);
                        for j = i:nbFa_inEl % !!! i
                            wejx = Wf{iG}(:,1,j);
                            wejy = Wf{iG}(:,2,j);
                            % ---
                            coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                (weix .* wejx + weiy .* wejy) );
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
                        weix = Wf{iG}(:,1,i);
                        weiy = Wf{iG}(:,2,i);
                        for j = i:nbFa_inEl % !!! i
                            wejx = Wf{iG}(:,1,j);
                            wejy = Wf{iG}(:,2,j);
                            % ---
                            coefwfwf(:,i,j) = coefwfwf(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* weix .* wejx +...
                                coefficient(:,1,2) .* weiy .* wejx +...
                                coefficient(:,2,1) .* weix .* wejy +...
                                coefficient(:,2,2) .* weiy .* wejy );
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
                args.vector_field = [1 1];
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
            %--------------------------------------------------------------
            if ~iscell(vector_field)
                vector_field = Array.vector(vector_field);
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
            vfx = cell(nbG,1);
            vfy = cell(nbG,1);
            if ~iscell(vector_field)
                for iG = 1:nbG
                    if numel(vector_field) == 2
                        vfx{iG} = vector_field(1);
                        vfy{iG} = vector_field(2);
                    elseif size(vector_field,1) >  length(id_elem) && ...
                           size(vector_field,1) == obj.nb_elem
                        vfx{iG} = vector_field(id_elem,1);
                        vfy{iG} = vector_field(id_elem,2);
                    else
                        vfx{iG} = vector_field(:,1);
                        vfy{iG} = vector_field(:,2);
                    end
                end
            else
                for iG = 1:nbG
                    vfx{iG} = vector_field{iG}(:,1);
                    vfy{iG} = vector_field{iG}(:,2);
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
                    % ---
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        coefwevf(:,i) = coefwevf(:,i) + ...
                            weigh .* dJ .* ( coefficient .* ...
                            (wix .* vix + wiy .* viy) );
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
                    % ---
                    for i = 1:nbEd_inEl
                        wix = We{iG}(:,1,i);
                        wiy = We{iG}(:,2,i);
                        coefwevf(:,i) = coefwevf(:,i) + ...
                            weigh .* dJ .* (...
                            coefficient(:,1,1) .* wix .* vix +...
                            coefficient(:,1,2) .* wiy .* vix +...
                            coefficient(:,2,1) .* wix .* viy +...
                            coefficient(:,2,2) .* wiy .* viy);
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
                args.vector_field = [1 1];
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
            %--------------------------------------------------------------
            if ~iscell(vector_field)
                vector_field = Array.vector(vector_field);
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
            vfx = cell(nbG,1);
            vfy = cell(nbG,1);
            if ~iscell(vector_field)
                for iG = 1:nbG
                    if numel(vector_field) == 2
                        vfx{iG} = vector_field(1);
                        vfy{iG} = vector_field(2);
                    elseif size(vector_field,1) >  length(id_elem) && ...
                           size(vector_field,1) == obj.nb_elem
                        vfx{iG} = vector_field(id_elem,1);
                        vfy{iG} = vector_field(id_elem,2);
                    else
                        vfx{iG} = vector_field(:,1);
                        vfy{iG} = vector_field(:,2);
                    end
                end
            else
                for iG = 1:nbG
                    vfx{iG} = vector_field{iG}(:,1);
                    vfy{iG} = vector_field{iG}(:,2);
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
                    % ---
                    for i = 1:nbFa_inEl
                        % ---
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        % ---
                        coefwfvf(:,i) = coefwfvf(:,i) + ...
                            weigh .* dJ .* ( coefficient .* ...
                            (wix .* vix + wiy .* viy) );
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
                    % ---
                    for i = 1:nbFa_inEl
                        % ---
                        wix = Wf{iG}(:,1,i);
                        wiy = Wf{iG}(:,2,i);
                        % ---
                        coefwfvf(:,i) = coefwfvf(:,i) + ...
                            weigh .* dJ .* (...
                            coefficient(:,1,1) .* wix .* vix +...
                            coefficient(:,1,2) .* wiy .* vix +...
                            coefficient(:,2,1) .* wix .* viy +...
                            coefficient(:,2,2) .* wiy .* viy);
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
            dof = Array.tensor(dof);
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
                scalar_field{i} = sparse(nb_elem,1);
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
                    scalar_field{iG}(id_elem,1) = fi;
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
            dof = Array.tensor(dof);
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
                vector_field{i} = sparse(nb_elem,2);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),2);
                    for i = 1:nbEd_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        id_edge = id_edge_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + coefficient .* wix .* dof(id_edge);
                        fi(:,2) = fi(:,2) + coefficient .* wiy .* dof(id_edge);
                    end
                    % ---
                    vector_field{iG}(id_elem,1:2) = fi;
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),2);
                    %------------------------------------------------------
                    for i = 1:nbEd_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        id_edge = id_edge_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + (coefficient(:,1,1) .* wix + ...
                                             coefficient(:,1,2) .* wiy) .* dof(id_edge) ;
                        fi(:,2) = fi(:,2) + (coefficient(:,2,1) .* wix + ...
                                             coefficient(:,2,2) .* wiy) .* dof(id_edge) ;
                    end
                    % ---
                    vector_field{iG}(id_elem,1:2) = fi;
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
            dof = Array.tensor(dof);
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
                vector_field{i} = sparse(nb_elem,2);
            end
            %--------------------------------------------------------------
            if any(f_strcmpi(coef_array_type,{'scalar'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),2);
                    for i = 1:nbFa_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        id_face = id_face_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + coefficient .* wix .* dof(id_face);
                        fi(:,2) = fi(:,2) + coefficient .* wiy .* dof(id_face);
                    end
                    % ---
                    vector_field{iG}(id_elem,1:2) = fi;
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),2);
                    %------------------------------------------------------
                    for i = 1:nbFa_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        id_face = id_face_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + (coefficient(:,1,1) .* wix + ...
                                             coefficient(:,1,2) .* wiy) .* dof(id_face) ;
                        fi(:,2) = fi(:,2) + (coefficient(:,2,1) .* wix + ...
                                             coefficient(:,2,2) .* wiy) .* dof(id_face) ;
                    end
                    % ---
                    vector_field{iG}(id_elem,1:2) = fi;
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

    % --- Methods - Plot
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
                args.field_value = []
            end
            %--------------------------------------------------------------
            mshalone = 1;
            forcomplx   = 1;
            forvector   = 1;
            fval     = [];
            for3d    = 0;
            if ~isempty(args.field_value)
                mshalone = 0;
                fval = f_column_format(args.field_value);
                % ---
                if isreal(fval)
                    forcomplx = 0;
                end
                % ---
                if size(fval,2) == 1
                    forvector = 0;
                end
                % ---
                if size(fval,2) == 3
                    for3d = 1;
                end
            end
            %--------------------------------------------------------------
            if forvector
                fx = fval(:,1);
                fy = fval(:,2);
                if for3d
                    fz = fval(:,3);
                end
            end
            %--------------------------------------------------------------
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            msh.Vertices = obj.node.';
            if isa(obj,'QuadMesh')
                msh.Faces = obj.elem(1:4,:).';
            elseif isa(obj,'TriMesh')
                msh.Faces = obj.elem(1:3,:).';
            end
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            if mshalone
                patch(msh);
            else
                if forvector
                    if forcomplx
                        % ---
                        subplot(131);
                        msh.FaceVertexCData = (f_magnitude(fval.')).';
                        patch(msh,'DisplayName','magnitude');
                        % ---
                        subplot(132);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','real-part'); hold on
                        f_quiver(obj.node,real(fval.'));
                        % ---
                        subplot(133);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','imag-part'); hold on
                        f_quiver(obj.node,imag(fval.'));
                    else
                        % ---
                        subplot(121);
                        msh.FaceVertexCData = (f_magnitude(fval.')).';
                        patch(msh,'DisplayName','magnitude');
                        % ---
                        subplot(122);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','vector-field'); hold on
                        f_quiver(obj.node,fval.');
                    end
                else
                    if forcomplx
                        % ---
                        subplot(121);
                        msh.FaceVertexCData = real(fval);
                        patch(msh,'DisplayName','real-part');
                        % ---
                        subplot(122);
                        msh.FaceVertexCData = imag(fval);
                        patch(msh,'DisplayName','imag-part');
                    else
                        msh.FaceVertexCData = fval;
                        patch(msh);
                    end
                end
            end
            %--------------------------------------------------------------
            xlabel('x (m)'); ylabel('y (m)');
            if size(obj.node,1) == 3
                zlabel('z (m)'); view(3);
            end
            axis equal; axis tight; alpha(alpha_); hold on
            %--------------------------------------------------------------
            f_chlogo;
        end
    end
end




