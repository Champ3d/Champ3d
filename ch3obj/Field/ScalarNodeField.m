%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef ScalarNodeField < NodeField
    % --- Contructor
    methods
        function obj = ScalarNodeField()
            obj = obj@NodeField;
        end
    end
    % --- plot
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.id_elem = []
                args.id_face = []
                args.show_dom = 0
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        if isempty(args.id_face)
                            text(0,0,'Nothing to plot !');
                            return
                        else
                            dom = SurfaceDom3d;
                            gindex = args.id_face;
                        end
                    else
                        dom = VolumeDom3d;
                        gindex = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    % ---
                    if isa(dom,'VolumeDom3d')
                        gindex = dom.gindex;
                    end
                    % ---
                    if isa(dom,'SurfaceDom3d')
                        gindex = dom.gindex;
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                % ---
                if isa(dom,'VolumeDom3d')
                    gindex = dom.gindex;
                end
                % ---
                if isa(dom,'SurfaceDom3d')
                    gindex = dom.gindex;
                end
            end
            % ---
            % if args.show_dom
            %     dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            % end
            % ---
            if isa(dom,'VolumeDom3d')
                node_ = obj.parent_model.moving_frame.node;
                elem = obj.parent_model.parent_mesh.elem(:,gindex);
                % ---
                f_patch('node',node_,'elem',elem,'node_field',obj.cvalue);
            end
            % ---
            if isa(dom,'SurfaceDom3d')
                node_ = obj.parent_model.moving_frame.node;
                face = obj.parent_model.parent_mesh.face(:,gindex);
                % ---
                f_patch('node',node_,'face',face,'node_field',obj.cvalue);
            end
        end
        % -----------------------------------------------------------------
    end
end