%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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
                elem = obj.parent_mesh.elem(:,obj.gid_elem);
                celem = obj.parent_mesh.celem(:,obj.gid_elem);
                velem = obj.parent_mesh.velem(obj.gid_elem);
            else isa(obj,'SurfaceDom')
                elem = obj.parent_mesh.face(:,obj.gid_face);
                celem = obj.parent_mesh.cface(:,obj.gid_face);
                velem = obj.parent_mesh.sface(obj.gid_elem);
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
    end
end