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

classdef FaceField < Xhandle
    % --- Contructor
    methods
        function obj = FaceField()
            obj = obj@Xhandle;
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cnode(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            val = obj.parent_model.parent_mesh.cface(:,id_face);
        end
        % -----------------------------------------------------------------
        function val = inode(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            lnb_face = length(dom.gid_face);
            % ---
            submesh = dom.submesh;
            % ---
            nbNodeI = submesh{1}.refelem.nbI;
            for i = 1:nbNodeI
                val{i} = zeros(lnb_face,3);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_prokit;
                % ---
                lid_face = sm.lid_face;
                inode = sm.prokit.node;
                % ---
                for i = 1:length(inode)
                    val{i}(lid_face,:) = inode{i};
                end
                % ---
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gnode(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            lnb_face = length(dom.gid_face);
            % ---
            submesh = dom.submesh;
            % ---
            nbNodeG = submesh{1}.refelem.nbG;
            for i = 1:nbNodeG
                val{i} = zeros(lnb_face,3);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face = sm.lid_face;
                gnode = sm.intkit.node;
                % ---
                for i = 1:length(gnode)
                    val{i}(lid_face,:) = gnode{i};
                end
                % ---
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
end