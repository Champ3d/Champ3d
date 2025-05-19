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

classdef StrandedOpenJsCoil < OpenCoil & StrandedCoil & JsCoil
    properties
        connexion = 'serial'
        cs_area = 1
        nb_turn = 1
        fill_factor = 1
        Js = 0
        coil_mode = 'tx'
        % ---
        matrix
    end
    properties (Access = private)
        build_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','parent_model','id_dom3d','etrode_equation', ...
                        'connexion','cs_area','nb_turn','fill_factor', ...
                        'Js','coil_mode'};
        end
    end
    % --- Contructor
    methods
        function obj = StrandedOpenJsCoil(args)
            arguments
                args.id
                args.parent_model
                args.id_dom3d
                args.etrode_equation
                % ---
                args.connexion {mustBeMember(args.connexion,{'serial','parallel'})}
                args.cs_area
                args.nb_turn
                args.fill_factor
                args.Js
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@OpenCoil;
            obj@StrandedCoil;
            obj@JsCoil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            StrandedOpenJsCoil.setup(obj);
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            % --- specific
            if isempty(obj.Js)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.Js)
                if obj.Js == 0
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
            obj.dofuJ = EdgeDof('parent_model',obj.parent_model);
            obj.uJfield = EdgeDofBasedVectorElemField('parent_model',obj.parent_model,'dof',obj.dofuJ);
            % --- Initialization
            obj.matrix.gid_elem = [];
            obj.matrix.js_array = [];
            obj.matrix.unit_current_field = [];
            obj.matrix.alpha = [];
            obj.matrix.current_turn_density = [];
            obj.matrix.wfjs = [];
            obj.matrix.t_js = [];
            % ---
            obj.build_done = 0;
        end
    end
    methods (Access = public)
        function reset(obj)
            StrandedOpenJsCoil.setup(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            dom = obj.dom;
            gid_elem = dom.gid_elem;
            % ---
            js_array = obj.Js.getvalue('in_dom',obj.dom);
            % --- check changes
            is_changed = 1;
            if isequal(js_array,obj.matrix.js_array) && ...
               isequal(gid_elem,obj.matrix.gid_elem)
                is_changed = 0;
            end
            %--------------------------------------------------------------
            if ~is_changed && obj.build_done == 1
                return
            end
            %--------------------------------------------------------------
            obj.matrix.gid_elem = gid_elem;
            obj.matrix.js_array = js_array;
            %--------------------------------------------------------------
            % OpenCoil first, then JsCoil
            % ---
            [unit_current_field,alpha,dofuJ_] = obj.get_uj_alpha;
            obj.matrix.unit_current_field = unit_current_field;
            obj.matrix.alpha = alpha;
            obj.matrix.current_turn_density = ...
                obj.matrix.unit_current_field .* obj.nb_turn ./ obj.cs_area;
            obj.dofuJ.value = dofuJ_;
            % ---
            if strcmpi(obj.coil_mode,'tx')
                [t_js,wfjs] = obj.get_t_js;
                obj.matrix.wfjs = wfjs;
                obj.matrix.t_js = t_js;
            end
            %--------------------------------------------------------------
            obj.build_done = 1;
        end
    end
    % --- assembly
    methods
        function assembly(obj)
            % ---
            obj.build;
            %--------------------------------------------------------------
            obj.parent_model.matrix.t_js = ...
                obj.parent_model.matrix.t_js + obj.matrix.t_js;
            %--------------------------------------------------------------
        end
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
        % -----------------------------------------------------------------
    end
    % --- Utility Methods
    methods
    % -----------------------------------------------------------------
        function getcircuitquantity(obj)
            it = obj.parent_model.ltime.it;
            % ---
            obj.getFlux;
            % ---
            jome = obj.parent_model.jome;
            if jome ~= 0
                obj.V(it) = - jome * obj.Flux;
                % ---
                switch obj.coil_mode
                    case 'rx'
                        obj.I(it) = 0;
                        obj.Z(it) = 0;
                        obj.L(it) = 0;
                        obj.R(it) = 0;
                        obj.P(it) = 0;
                        obj.Q(it) = 0;
                    case 'tx'
                        obj.I(it) = obj.matrix.js_array(1) * obj.cs_area;
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