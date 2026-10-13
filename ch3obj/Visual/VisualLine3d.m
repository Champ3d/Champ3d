%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef VisualLine3d < Xhandle

    properties
        parent_model = []
        p0
        p1
        dnum
        %dtype
    end

    properties
        finterpolant
    end

    % --- Dependent Properties
    properties (Dependent = true)
        node
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {};
        end
    end
    % --- Constructors
    methods
        function obj = VisualLine3d(args)
            arguments
                args.parent_model
                args.p0
                args.p1
                args.dnum
                args.dtype
            end
            % ---
            obj = obj@Xhandle;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.parent_model)
                obj.setup;
            end
            % ---
        end
    end
    % --- set
    methods
        function set.parent_model(obj,pmodel)
            obj.parent_model = pmodel;
            obj.setup;
        end
    end
    % --- get
    methods
        function val = get.node(obj)
            val = zeros(3,obj.dnum);
            for i = 1:3
                val(i,:) = linspace(obj.p0(i),obj.p1(i),obj.dnum);
            end
        end
    end
    % --- setup
    methods
        function setup(obj)
            if isempty(obj.parent_model.parent_mesh.prokit.node)
                obj.parent_model.parent_mesh.build_prokit;
            end
            interp_node = obj.parent_model.parent_mesh.prokit.node;
            nbINode = length(interp_node);
            nb_elem = obj.parent_model.parent_mesh.nb_elem;
            % ---
            node_i = zeros(nbINode * nb_elem, 3);
            % ---
            id0 = 1:nb_elem;
            for k = 1:nbINode
                idn = id0 + (k - 1) * nb_elem;
                node_i(idn,:) = interp_node{k}(id0,:);
            end
            % ---
            valx = zeros(nbINode * nb_elem, 1);
            obj.finterpolant = scatteredInterpolant(node_i,valx,'linear','none');
            % ---
        end
    end
    % --- plot
    methods
        function plot(obj,args)
            arguments
                obj
                args.it = 0
                args.field_name {mustBeMember(args.field_name,{'B','H','J','E','A','P'})}
            end
            % ---
            id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            % ---
            if args.it == 0
                it = 1;
            else
                it = args.it;
            end
            field_name = args.field_name;
            % ---
            fval = obj.getfield("it",it,"field_name",field_name);
            % ---
            if size(fval,1) == 3
                f_quiver(obj.node,fval);
            end
        end
        % ---
        function fval = getfield(obj,args)
            arguments
                obj
                args.it = 0
                args.field_name {mustBeMember(args.field_name,{'B','H','J','E','A','P'})}
            end
            % ---
            if args.it == 0
                it = 1;
            else
                it = args.it;
            end
            field_name = args.field_name;
            % ---
            nb_elem = obj.parent_model.parent_mesh.nb_elem;
            id_elem = 1:nb_elem;
            % ---
            node_ = obj.node;
            nb_node = size(node_,2);
            % ---
            valcell =+ obj.parent_model.field{it}.(field_name).elem({id_elem});
            nbINode = length(valcell);
            % ---
            dim_ = size(valcell{1},2);
            fval = zeros(nb_node,dim_);
            % ---
            for i = 1:dim_
                valx = zeros(nbINode * nb_elem, 1);
                % ---
                id0 = 1:nb_elem;
                for k = 1:nbINode
                    idn = id0 + (k - 1) * nb_elem;
                    valx(idn) = valcell{k}(:,i);
                end
                % ---
                obj.finterpolant.Values = valx;
                % ---
                fval(:,i) = obj.finterpolant(node_.');
                % ---
            end
            % ---
            fval = fval.';
            % ---
        end
    end
    % --- utility
    methods (Access = private)

    end
end



