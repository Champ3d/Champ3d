%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThPs < PhysicalDom

    properties
        ps = 0
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
    end

    % --- Contructor
    methods
        function obj = ThPs(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.ps
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
            obj.setup_done = 0;
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
            setup@PhysicalDom(obj);
            % ---
            if isnumeric(obj.ps)
                obj.ps = Parameter('f',obj.ps);
            end
            % ---
            obj.setup_done = 1;
        end
    end
end
