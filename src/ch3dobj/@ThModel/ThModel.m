%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ThModel < Xhandle
    properties
        id
        % ---
        parent_mesh
        % ---
        tconductor
        tcapacitor
        bc_convection
        bc_radiation
        % ---
        matrix
        fields
    end

    % --- Constructor
    methods
        function obj = ThModel(args)
            arguments
                args.id = 'no_id'
                % ---
                args.parent_mesh = []
            end
            % ---
            obj <= args;
            % ---
            obj.init('property_name','fields',...
                     'field_name',{'tempv','temps'}, ...
                     'init_value',2.*ones(1,obj.parent_mesh.nb_elem));
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function add_tconductor(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
                args.lambda = 0
            end
            % ---
            args.parent_model = obj;
            % ---
            phydom = Econductor(args);
            obj.tconductor.(args.id) = phydom;
        end
        % -----------------------------------------------------------------
        function add_tcapacitor(obj,args)
            
        end
        % -----------------------------------------------------------------
        function add_thbc(obj)
        end
    end

    % --- Methods/Abs
    methods
        function build(obj)
        end
        function solve(obj)
        end
        function postpro(obj)
        end
    end
end