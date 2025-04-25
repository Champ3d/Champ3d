%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalModel < Xhandle

    properties
        parent_mesh
        ltime
        moving_frame
        % ---
        visualdom
        % ---
        matrix
        field
        dof
    end

    % --- Constructor
    methods
        function obj = PhysicalModel()
            % ---
            obj@Xhandle;
            % --- initialization
            obj.ltime = LTime;
        end
    end
    % --- Utility Methods
    % --- build
    methods
        % ---
        function build(obj)
            obj.parent_mesh.build;
        end
        % ---
        function add_ltime(obj,ltime_obj)
            arguments
                obj
                % ---
                ltime_obj {mustBeA(ltime_obj,'LTime')}
            end
            % ---
            obj.ltime = ltime_obj;
            % ---
        end
    end
    % --- visualization
    methods
        function add_visualdom(obj,args)
            arguments
                obj
                % ---
                args.id = 'no_id'
                args.id_dom2d = []
                args.id_dom3d = []
            end
            % ---
            dom = PhysicalDom;
            dom.id_dom2d = args.id_dom2d;
            dom.id_dom3d = args.id_dom3d;
            dom.parent_model = obj;
            dom.get_geodom;
            % ---
            obj.visualdom.(args.id) = dom;
        end
    end
end