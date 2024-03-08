%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef StrandedCoil < Coil
    properties
        connexion = 'serie'
        cs_area = 1
        nb_turn = 1
        fill_factor = 1
    end

    % --- Contructor
    methods
        function obj = StrandedCoil(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.connexion
                args.cs_area
                args.nb_turn
                args.fill_factor
            end
            % ---
            obj@Coil;
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
                setup@Coil(obj);
                % ---
                obj.setup_ready = 1;
            end
        end
    end

end