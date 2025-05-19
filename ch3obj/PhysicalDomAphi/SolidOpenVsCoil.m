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

classdef SolidOpenVsCoil < OpenCoil & SolidCoil & VsCoil
    properties
        Vs = 0
        coil_mode = 'tx'
        % ---
        matrix
    end
    % --- 
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','etrode_equation',...
                'Vs','coil_mode'};
        end
    end
    % --- Contructor
    methods
        function obj = SolidOpenVsCoil(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.etrode_equation
                % ---
                args.Vs
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@OpenCoil;
            obj@SolidCoil;
            obj@VsCoil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            SolidOpenVsCoil.setup(obj);
            % ---
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            % --- specific
            if isempty(obj.Vs)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.Vs)
                if obj.Vs == 0
                    obj.coil_mode = 'rx';
                end
            end
            % ---
            obj.etrode_equation = f_to_scellargin(obj.etrode_equation);
            % --- call utility methods
            obj.set_parameter;
            obj.get_geodom;
            obj.dom.is_defining_obj_of(obj);
            % XTODO - surfacedom
            % obj.petrode.is_defining_obj_of(obj);
            % obj.netrode.is_defining_obj_of(obj);
            % --- specific
            obj.get_electrode;
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.vs_array = [];
            obj.matrix.unit_current_field = [];
            obj.matrix.alpha = [];
            % ---
            obj.build_done = 0;
        end
    end
    methods (Access = public)
        function reset(obj)
            SolidOpenVsCoil.setup(obj);
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            gid_elem = dom.gid_elem;
            % ---
            vs_array = obj.Vs.getvalue('in_dom',obj.dom);
            % --- check changes
            is_changed = 1;
            if isequal(vs_array,obj.matrix.vs_array) && ...
               isequal(gid_elem,obj.matrix.gid_elem)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.vs_array = vs_array;
            %--------------------------------------------------------------
            % OpenCoil first, then VsCoil
            % ---
            [unit_current_field,alpha] = obj.get_uj_alpha;
            obj.matrix.unit_current_field = unit_current_field;
            obj.matrix.alpha = alpha;
            % ---
        end
    end
    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.id_node_netrode = ...
                unique([obj.parent_model.matrix.id_node_netrode obj.gid_node_netrode]);
            obj.parent_model.matrix.id_node_petrode = ...
                unique([obj.parent_model.matrix.id_node_petrode obj.gid_node_petrode]);
            %--------------------------------------------------------------
            % obj.parent_model.matrix.alpha = ...
            %     obj.parent_model.matrix.alpha + obj.matrix.alpha;
            %--------------------------------------------------------------
        end
    end
    % --- get
    methods

    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function plot(obj)
            % ---
            obj.dom.plot('face_color','none'); hold on
            % ---
            plot@OpenCoil(obj);
            % ---
        end
    end
    % --- Utility Methods
    methods
    % -----------------------------------------------------------------
        function getcircuitquantity(obj)
            it = obj.parent_model.ltime.it;
            % ---
            jome = obj.parent_model.jome;
            if jome ~= 0
                % --- XTODO
                switch obj.coil_mode
                    case 'rx'
                        obj.I(it) = 0;
                        obj.Z(it) = 0;
                        obj.L(it) = 0;
                        obj.R(it) = 0;
                        obj.P(it) = 0;
                        obj.Q(it) = 0;
                    case 'tx'
                        obj.Z(it) = obj.V(it) / obj.I(it);
                        obj.L(it) = imag(obj.Z(it)) / abs(jome);
                        obj.R(it) = real(obj.Z(it));
                        obj.P(it) = 1/2 * real(obj.V(it) * conj(obj.I(it)));
                        obj.Q(it) = 1/2 * imag(obj.V(it) * conj(obj.I(it)));
                end
                % ---
            end
        end
    end
end