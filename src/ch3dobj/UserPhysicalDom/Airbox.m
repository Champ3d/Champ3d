%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Airbox < PhysicalDom
    properties

    end

    % --- Contructor
    methods
        function obj = Airbox(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
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
end