%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef StrandedOpenJsCoil < StrandedCoil & OpenCoil
    properties
        coil_mode = 'tx'
    end

    % --- Contructor
    methods
        function obj = StrandedOpenJsCoil(args)
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
            obj@StrandedCoil;
            obj@OpenCoil;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_ready = 0;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            if ~obj.setup_ready
                % ---
                setup@StrandedCoil(obj);
                obj.setup_ready = 0;
                setup@OpenCoil(obj);
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
                obj.setup_ready = 1;
            end
        end
    end

    % --- Methods
    methods
        function plot(obj)
            plot@OpenCoil(obj);
        end
    end

end