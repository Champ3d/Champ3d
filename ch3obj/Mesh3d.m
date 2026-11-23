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

classdef Mesh3d < Mesh
    % --- Constructors
    methods
        function obj = Mesh3d()
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
                args.id_dom2d = []
                args.id_zline = []
                args.elem_code = []
                args.gindex = []
                args.condition char = []
                % ---
                args.id_dom3d = [];
                args.cut_equation = [];
                % ---
                args.dom_obj {mustBeA(args.dom_obj,{'VolumeDom3d','CutVolumeDom3d'})}
            end
            % ---
            if isempty(args.id)
                error('#id must be given !');
            end
            % ---
            if ~isfield(args,'dom_obj')
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
            else
                % for dom created by dom operation
                % no more need to def defining_obj
                dom = args.dom_obj;
                dom.id = args.id;
                obj.dom.(args.id) = dom;
            end
        end
        % -----------------------------------------------------------------
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char = []
                % ---
                args.defined_on {mustBeMember(args.defined_on,{'bound','bound_face','interface'})}
                args.id_dom3d = []
                % ---
                args.elem_code = []
                args.gindex = []
                args.condition char = []
                % ---
                args.dom_obj {mustBeA(args.dom_obj,{'SurfaceDom3d'})}
            end
            % ---
            if isempty(args.id)
                error('#id must be given !');
            end
            % ---
            if ~isfield(args,'defined_on')
                args.defined_on = '';
            end
            % --- surface dom is always created from vdom
            % no more need to def defining_obj
            if ~isfield(args,'dom_obj')
                % ---
                args.parent_mesh = obj;
                % ---
                argu = f_to_namedarg(args,'for','SurfaceDom3d');
                dom = SurfaceDom3d(argu{:});
                obj.dom.(args.id) = dom;
            else
                dom = args.dom_obj;
                dom.id = args.id;
                obj.dom.(args.id) = dom;
            end
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
            [coefficient, coef_array_type] = Array.tensor(coefficient);
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
            vfz = cell(nbG,1);
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
            vfz = cell(nbG,1);
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
        function coefvfwfxwe = cvfwfxwe(obj,args)
            arguments
                obj
                args.id_elem = []
                args.coefficient = 1
                args.vector_field = [1 1 1];
                args.order = '0'
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
            coefvfwfxwe = zeros(nb_elem,nbFa_inEl,nbEd_inEl);
            %--------------------------------------------------------------
            vfx = cell(nbG,1);
            vfy = cell(nbG,1);
            vfz = cell(nbG,1);
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
            if any(f_strcmpi(coef_array_type,{'scalar'}))
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
                        % weix = We{iG}(:,1,i);
                        % weiy = We{iG}(:,2,i);
                        % weiz = We{iG}(:,3,i);
                        % ---
                        wfix = Wf{iG}(:,1,i);
                        wfiy = Wf{iG}(:,2,i);
                        wfiz = Wf{iG}(:,3,i);
                        for j = 1:nbEd_inEl % !!! 1
                            % wfjx = Wf{iG}(:,1,j);
                            % wfjy = Wf{iG}(:,2,j);
                            % wfjz = Wf{iG}(:,3,j);
                            % ---
                            wejx = We{iG}(:,1,j);
                            wejy = We{iG}(:,2,j);
                            wejz = We{iG}(:,3,j);
                            % ---
                            coefvfwfxwe(:,i,j) = coefvfwfxwe(:,i,j) + ...
                                weigh .* dJ .* ( coefficient .* ...
                                ( vix .* (wfiy .* wejz - wfiz .* wejy) + ...
                                  viy .* (wfiz .* wejx - wfix .* wejz) + ...
                                  viz .* (wfix .* wejy - wfiy .* wejx) ));
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
                        wejx = We{iG}(:,1,i);
                        wejy = We{iG}(:,2,i);
                        wejz = We{iG}(:,3,i);
                        for j = 1:nbFa_inEl % !!! 1
                            wfix = Wf{iG}(:,1,j);
                            wfiy = Wf{iG}(:,2,j);
                            wfiz = Wf{iG}(:,3,j);
                            % ---
                            coefvfwfxwe(:,i,j) = coefvfwfxwe(:,i,j) + ...
                                weigh .* dJ .* (...
                                coefficient(:,1,1) .* wejx .* wfix +...
                                coefficient(:,1,2) .* wejy .* wfix +...
                                coefficient(:,1,3) .* wejz .* wfix +...
                                coefficient(:,2,1) .* wejx .* wfiy +...
                                coefficient(:,2,2) .* wejy .* wfiy +...
                                coefficient(:,2,3) .* wejz .* wfiy +...
                                coefficient(:,3,1) .* wejx .* wfiz +...
                                coefficient(:,3,2) .* wejy .* wfiz +...
                                coefficient(:,3,3) .* wejz .* wfiz );
                        end
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
            obj.build_intkit;
            switch on_
                case 'center'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWn{iG}(id_elem,:);
                    end
                case 'gauss_points'
                    nbG = refelem.nbG;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.Wn{iG}(id_elem,:);
                    end
                case 'interpolation_points'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWn{iG}(id_elem,:);
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
            obj.build_intkit;
            switch on_
                case 'center'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                    end
                case 'gauss_points'
                    nbG = refelem.nbG;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.We{iG}(id_elem,:,:);
                    end
                case 'interpolation_points'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWe{iG}(id_elem,:,:);
                    end
            end
            %--------------------------------------------------------------
            vector_field = cell(nbG,1);
            for i = 1:nbG
                vector_field{i} = sparse(nb_elem,3);
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
                    vector_field{iG}(id_elem,1:3) = fi;
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),3);
                    %------------------------------------------------------
                    for i = 1:nbEd_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        wiz = Wx{iG}(:,3,i);
                        id_edge = id_edge_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + (coefficient(:,1,1) .* wix + ...
                                             coefficient(:,1,2) .* wiy + ...
                                             coefficient(:,1,3) .* wiz) .* dof(id_edge) ;
                        fi(:,2) = fi(:,2) + (coefficient(:,2,1) .* wix + ...
                                             coefficient(:,2,2) .* wiy + ...
                                             coefficient(:,2,3) .* wiz) .* dof(id_edge) ;
                        fi(:,3) = fi(:,3) + (coefficient(:,3,1) .* wix + ...
                                             coefficient(:,3,2) .* wiy + ...
                                             coefficient(:,3,3) .* wiz) .* dof(id_edge) ;
                    end
                    % ---
                    vector_field{iG}(id_elem,1:3) = fi;
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
            obj.build_intkit;
            switch on_
                case 'center'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
                    end
                case 'gauss_points'
                    nbG = refelem.nbG;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.Wf{iG}(id_elem,:,:);
                    end
                case 'interpolation_points'
                    nbG = 1;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.intkit.cWf{iG}(id_elem,:,:);
                    end
            end
            %--------------------------------------------------------------
            vector_field = cell(nbG,1);
            for i = 1:nbG
                vector_field{i} = sparse(nb_elem,3);
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
                    vector_field{iG}(id_elem,1:3) = fi;
                end
                % ---
                if nbG == 1
                    vector_field = vector_field{1};
                end
                %----------------------------------------------------------
            elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                %----------------------------------------------------------
                for iG = 1:nbG
                    fi = zeros(length(id_elem),3);
                    %------------------------------------------------------
                    for i = 1:nbFa_inEl
                        wix = Wx{iG}(:,1,i);
                        wiy = Wx{iG}(:,2,i);
                        wiz = Wx{iG}(:,3,i);
                        id_face = id_face_in_elem(i,id_elem);
                        fi(:,1) = fi(:,1) + (coefficient(:,1,1) .* wix + ...
                                             coefficient(:,1,2) .* wiy + ...
                                             coefficient(:,1,3) .* wiz) .* dof(id_face) ;
                        fi(:,2) = fi(:,2) + (coefficient(:,2,1) .* wix + ...
                                             coefficient(:,2,2) .* wiy + ...
                                             coefficient(:,2,3) .* wiz) .* dof(id_face) ;
                        fi(:,3) = fi(:,3) + (coefficient(:,3,1) .* wix + ...
                                             coefficient(:,3,2) .* wiy + ...
                                             coefficient(:,3,3) .* wiz) .* dof(id_face) ;
                    end
                    % ---
                    vector_field{iG}(id_elem,1:3) = fi;
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

    % --- Sample mesh
    methods (Static)
        function m3d = samplemesh01(args)
        arguments
            args.elem_type {mustBeMember(args.elem_type,{'hex','prism','tetra'})} = 'hex'
            args.ri = 0
            args.ro = 1
            args.rair = 0
            args.tlayer = 5e-3
            args.nb_layer = 3
            args.dnum = []
        end
        % --- default values
        dnum.zair = 4; dnum.layer = 1; dnum.angle = 12; dnum.ri = 2; dnum.ro = 3; dnum.rair = 4;
        % ---
        ri = args.ri; ro = args.ro; rair = args.rair; tlayer = args.tlayer; nb_layer = args.nb_layer;
        if ri <= 0 || ri >= ro, ri = ro/2; end
        if nb_layer <= 0, nb_layer = 1; end
        if rair > 0 && rair <= ro, rair = 2*ro; end
        % ---
        fname = fieldnames(dnum);
        for i = 1:length(fname), if isfield(args.dnum,fname{i}), dnum.(fname{i}) = args.dnum.(fname{i}); end; end
        % ------------------------------------------------------------------------------------------------------------------
        % --- z mesh1d
        m1d_z = Mesh1d();
        m1d_z.add_line1d("id","zabox_1" ,"len",rair,"dnum",dnum.zair,"dtype","log-");
        for i = 1:nb_layer
            idz = ['zlayer_' num2str(i)]; m1d_z.add_line1d("id",idz,"len",tlayer,"dnum",dnum.layer,"dtype","lin");
        end
        m1d_z.add_line1d("id","zabox_2" ,"len",rair,"dnum",dnum.zair,"dtype","log+");
        % ------------------------------------------------------------------------------------------------------------------
        switch args.elem_type
            case 'hex'
                if rair <= 0
                    m2d = QuadMeshCircles('id_dom',{'ri','ro'},'radius',[ri,ro],'anum',dnum.angle,'rnum',[dnum.ri,dnum.ro],'rtype',{'lin','lin'});
                else
                    m2d = QuadMeshCircles('id_dom',{'ri','ro','rair'},'radius',[ri,ro,rair],'anum',dnum.angle,'rnum',[dnum.ri,dnum.ro,dnum.rair],'rtype',{'lin','lin','log+'});
                end
                % ---
                m3d = HexaMeshFromQuadMesh("parent_mesh2d",m2d,"parent_mesh1d",m1d_z,"id_zline",{'z...'});
                m3d.lock_origin("gcoordinates",[0, 0, rair]);
            case 'prism'
                if dnum.angle < 20, dnum.angle = 20; end
                shape2d = {};
                shape2d{1} = SCircle("id","ri","center",[0 0],"r",ri,"dnum",dnum.angle,"choosed_by","top");
                shape2d{2} = SCircle("id","ro","center",[0 0],"r",ro,"dnum",dnum.angle,"choosed_by","top");
                if rair > 0, shape2d{3} = SCircle("id","rair","center",[0 0],"r",rair,"dnum",dnum.angle,"choosed_by","top"); end
                % ---
                m2d = TriMeshFromPDETool("shape",shape2d,"hgrad",1.3,"hmax",1e6);
                m2d.add_vdom("id","ri","elem_code",3); m2d.add_vdom("id","ro","elem_code",1); m2d.add_vdom("id","rair","elem_code",2);
                % ---
                m3d = PrismMeshFromTriMesh("parent_mesh2d",m2d,"parent_mesh1d",m1d_z,"id_zline",{'z...'});
                m3d.lock_origin("gcoordinates",[0, 0, rair]);
            case 'tetra'
                shape3d_ring = {};
                shape3d_ri = {};
                for i = 1:nb_layer
                    zcen = tlayer/2 + (i-1) * tlayer;
                    shape3d_ri{i} = BCylinder('center',[0 0 zcen],'r',ri,'hei',tlayer,'opening_angle',360,'orientation',[0 0 1]);
                    shape3d_ring{i} = BHollowCylinder('center',[0 0 zcen],'ri',ri,'ro',ro,'hei',tlayer,'opening_angle',360,'orientation',[0 0 1]);
                end
                % --- airbox shape
                shape3d_air = BSphere('center',[0, 0, nb_layer*tlayer/2],'r',rair+nb_layer*tlayer/2);
                % --- Physical Volume
                vdom = {};
                for i = 1:nb_layer
                    idri = ['ri_' num2str(i)];
                    idring = ['ring_' num2str(i)];
                    vdom{end+1} = PhysicalVolume('id',idri,'volume_shape',shape3d_ri{i},'mesh_size',ri/(2*dnum.ri));
                    vdom{end+1} = PhysicalVolume('id',idring,'volume_shape',shape3d_ring{i},'mesh_size',ro/(2*dnum.ro));
                end
                % --- Airbox Volume
                airdom = AirboxVolume('id','air','volume_shape',shape3d_air);
                % --- Mesh
                m3d = TetraMeshFromGMSH('id','samplemesh_tetra','physical_volume',vdom,'airbox_volume',airdom);
                % --- vdom update
                for i = 1:nb_layer
                    idlayer = ['layer_' num2str(i)];
                    idri = ['ri_' num2str(i)];
                    idring = ['ring_' num2str(i)];
                    vdomlayer = m3d.dom.(idri) + m3d.dom.(idring);
                    m3d.add_vdom("id",idlayer,"dom_obj",vdomlayer);
                end
                % ---
        end
        % --- vdom
        switch args.elem_type
            case {'hex','prism'}
                for i = 1:nb_layer
                    idz = ['zlayer_' num2str(i)];
                    idl = ['layer_' num2str(i)]; m3d.add_vdom("id",idl,"id_dom2d",{'ri','ro'},"id_zline",idz);
                    idl = ['ring_' num2str(i)]; m3d.add_vdom("id",idl,"id_dom2d",'ro',"id_zline",idz);
                    idl = ['ri_' num2str(i)]; m3d.add_vdom("id",idl,"id_dom2d",'ri',"id_zline",idz);
                end
        end
        % --- sdom
        for i = 1:nb_layer
            idl = ['layer_' num2str(i)]; m3d.add_sdom("id",['s' idl],"defined_on","bound","id_dom3d",idl);
            idl = ['ring_' num2str(i)]; m3d.add_sdom("id",['s' idl],"defined_on","bound","id_dom3d",idl);
            idl = ['ri_' num2str(i)]; m3d.add_sdom("id",['s' idl],"defined_on","bound","id_dom3d",idl);
        end
        % ---
        end
    end
end




