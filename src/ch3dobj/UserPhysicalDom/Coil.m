%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Coil < PhysicalDom
    properties
        connexion
        source_type
        coil_type
        coil_mode
        i_coil
        v_coil
        j_coil
        %sigma
    end

    % --- Contructor
    methods
        function obj = Coil(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.connexion
                args.source_type
                args.coil_type
                args.coil_mode
                args.i_coil
                args.v_coil
                args.j_coil
            end
            % ---
            obj = obj@PhysicalDom;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.to_be_rebuild = 1;
            % ---
            obj.build;
        end
    end
    
    % --- build
    methods
        function build(obj)
            if obj.to_be_rebuild
                % ---
                build@PhysicalDom(obj);
                % ---
            end
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'none'
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            plot@PhysicalDom(obj,argu{:}); hold on
        end
        % -----------------------------------------------------------------
    end
end