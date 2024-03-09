%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef StrandedCloseJsCoilAphi < CloseCoilAphi

    % --- computed
    properties
        build_done = 0
        matrix
    end

    % --- Contructor
    methods
        function obj = StrandedCloseJsCoilAphi(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.connexion
                args.cs_area
                args.nb_turn
                args.fill_factor
                args.etrode_equation
                % ---
                args.j_coil
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@StrandedCloseJsCoil;
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
            if ~obj.setup_done
                % ---
                setup@StrandedCloseJsCoil(obj);
                % ---
                obj.setup_done = 1;
                % ---
                obj.build_done = 0;
            end
        end
    end

    % --- build
    methods
        function build(obj)
            if ~obj.setup_done
                obj.setup;
            end
            % ---
            if ~obj.build_done
                % ---
                
                % ---
                obj.build_done = 1;
            end
        end
    end

    % --- Methods
    methods
        function plot(obj)
            plot@StrandedCloseJsCoil(obj);
        end
    end

end