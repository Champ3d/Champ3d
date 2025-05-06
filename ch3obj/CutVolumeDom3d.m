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

classdef CutVolumeDom3d < VolumeDom3d

    % --- Properties
    properties
        id_dom3d
        cut_equation
        gid_side_node_1
        gid_side_node_2
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','id_dom3d','cut_equation'};
        end
    end
    % --- Constructors
    methods
        function obj = CutVolumeDom3d(args)
            arguments
                % ---
                args.parent_mesh = []
                args.id_dom3d = []
                args.cut_equation = []
            end
            % ---
            obj = obj@VolumeDom3d;
            % ---
            obj <= args;
            % ---
            if ~isempty(obj.id_dom3d) && ~isempty(obj.cut_equation)
                obj.build;
            end
            % ---
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function build(obj)
            % ---
            gid_elem_ = [];
            gid_side_node_1_ = [];
            gid_side_node_2_ = [];
            iddom3 = f_to_scellargin(obj.id_dom3d);
            for i = 1:length(iddom3)
                dom2cut = obj.parent_mesh.dom.(iddom3{i});
                cut_dom = dom2cut.get_cutdom('cut_equation',obj.cut_equation);
                gid_elem_ = [gid_elem_ cut_dom.gid_elem];
                gid_side_node_1_ = [gid_side_node_1_ cut_dom.gid_side_node_1];
                gid_side_node_2_ = [gid_side_node_2_ cut_dom.gid_side_node_2];
            end
            % ---
            obj.gid_elem = gid_elem_;
            obj.gid_side_node_1 = gid_side_node_1_;
            obj.gid_side_node_2 = gid_side_node_2_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end

    % ---
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            plot@VolumeDom(obj,argu{:}); hold on
            % side 1
            x = obj.parent_mesh.node(1,obj.gid_side_node_1);
            y = obj.parent_mesh.node(2,obj.gid_side_node_1);
            z = obj.parent_mesh.node(3,obj.gid_side_node_1);
            plot3(x,y,z,'or','MarkerFaceColor','r'); hold on
            % side 1
            x = obj.parent_mesh.node(1,obj.gid_side_node_2);
            y = obj.parent_mesh.node(2,obj.gid_side_node_2);
            z = obj.parent_mesh.node(3,obj.gid_side_node_2);
            plot3(x,y,z,'ob','MarkerFaceColor','b');
            % -------------------------------------------------------------
        end
    end

end



