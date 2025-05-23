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

classdef MeshDom < Xhandle
    % --- Dependent Properties
    properties (Dependent = true)
        geoextension
    end
    % --- Constructors
    methods
        function obj = MeshDom()
            obj = obj@Xhandle;
        end
    end
    % --- Utility Methods
    methods
        function val = get.geoextension(obj)
            % ---
            if isa(obj,'VolumeDom')
                elem = obj.parent_mesh.elem(:,obj.gindex);
                celem = obj.parent_mesh.celem(:,obj.gindex);
                velem = obj.parent_mesh.velem(obj.gindex);
            else isa(obj,'SurfaceDom')
                elem = obj.parent_mesh.face(:,obj.gindex);
                celem = obj.parent_mesh.cface(:,obj.gindex);
                velem = obj.parent_mesh.sface(obj.gindex);
            end
            % ---
            id_node = f_uniquenode(elem);
            node = obj.parent_mesh.node(:,id_node);
            % ---
            val.xmin = min(node(1,:));
            val.ymin = min(node(2,:));
            val.xmax = max(node(1,:));
            val.ymax = max(node(2,:));
            val.xcen = mean(celem(1,:) .* velem.');
            val.ycen = mean(celem(2,:) .* velem.');
            if size(node,1) == 3
                val.zmin = min(node(3,:));
                val.zmax = max(node(3,:));
                val.zcen = mean(celem(3,:) .* velem.');
            else
                val.zmin = 0;
                val.zmax = 0;
                val.zcen = 0;
            end
            % ---
        end
        % ----------
        function set.geoextension(obj,val)
            
        end
    end
end