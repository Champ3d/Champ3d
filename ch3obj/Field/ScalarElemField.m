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

classdef ScalarElemField < ElemField
    methods
        function obj = ScalarElemField()
            obj = obj@ElemField;
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
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        text(0,0,'Nothing to plot !');
                    else
                        gid_elem = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'VolumeDom3d')
                        gid_elem = dom.gid_elem;
                    else
                        text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'VolumeDom3d')
                    gid_elem = dom.gid_elem;
                else
                    text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            node_ = obj.parent_model.parent_mesh.node;
            elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
            f_patch('node',node_,'elem',elem,'elem_field',obj.cvalue(gid_elem));
        end
        % -----------------------------------------------------------------
    end
end