%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
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
        tarray
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
    % --- ltime + visualization
    methods
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
        % ---
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