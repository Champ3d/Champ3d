%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef SolidOpenVsCoilAphi < OpenCoilAphi & SolidCoilAphi & VsCoilAphi
    
    % --- entry
    properties
        v_coil = 0
        coil_mode = 'rx'
    end

    % --- computed
    properties
        j_coil
        i_coil
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
        function obj = SolidOpenVsCoilAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
                % ---
                args.sigma
                args.v_coil
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@OpenCoilAphi;
            obj@SolidCoilAphi;
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
            setup@OpenCoilAphi(obj);
            obj.setup_done = 0;
            setup@SolidCoilAphi(obj);
            % ---
            if isempty(obj.v_coil)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.v_coil)
                if obj.v_coil == 0
                    obj.coil_mode = 'rx';
                end
                % ---
                obj.v_coil = Parameter('f',obj.v_coil);
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
            build@OpenCoilAphi(obj);
            build@VsCoilAphi(obj);
            % ---
            obj.build_done = 1;
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
            plot@OpenCoilAphi(obj,argu{:});
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