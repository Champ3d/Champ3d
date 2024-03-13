%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef StrandedCloseJsCoilAphi < CloseCoilAphi & StrandedCoilAphi & JsCoilAphi
    
    % --- entry
    properties
        connexion {mustBeMember(connexion,{'serial','parallel'})} = 'serial'
        cs_area = 1
        nb_turn = 1
        fill_factor = 1
        j_coil = 0
        coil_mode = 'rx'
    end

    % --- computed
    properties
        i_coil
        v_coil
        z_coil
        L0
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Contructor
    methods
        function obj = StrandedCloseJsCoilAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
                % ---
                args.connexion
                args.cs_area
                args.nb_turn
                args.fill_factor
                args.j_coil
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@CloseCoilAphi;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_done = 0;
            obj.build_done = 0;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            if obj.setup_done
                return
            end
            % ---
            setup@CloseCoilAphi(obj);
            % ---
            if isempty(obj.j_coil)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.j_coil)
                if obj.j_coil == 0
                    obj.coil_mode = 'rx';
                end
                % ---
                obj.j_coil = Parameter('f',obj.j_coil);
            end
            % ---
            obj.setup_done = 1;
            % ---
            obj.build_done = 0;
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            obj.setup;
            % ---
            if obj.build_done
                return
            end
            % ---
            build@CloseCoilAphi(obj);
            build@JsCoilAphi(obj);
        end
    end

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'k'
                args.face_color = 'none'
                args.alpha {mustBeNumeric} = 0.5
            end
            % ---
            argu = f_to_namedarg(args);
            plot@CloseCoilAphi(obj,argu{:});
            % ---
        end
    end

    % --- reset
    methods
        function reset(obj)
            if isprop(obj,'setup_done')
                obj.setup_done = 0;
            end
            if isprop(obj,'build_done')
                obj.build_done = 0;
            end
            if isprop(obj,'assembly_done')
                obj.assembly_done = 0;
            end
        end
    end

end