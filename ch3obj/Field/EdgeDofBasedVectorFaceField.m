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

classdef EdgeDofBasedVectorFaceField < VectorFaceField
    properties
        parent_model
        dof
    end
    % --- Contructor
    methods
        function obj = EdgeDofBasedVectorFaceField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'EdgeDof')}
            end
            % ---
            obj = obj@VectorFaceField;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                    error('#parent_model and #dof must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cvalue(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            if isempty(id_face)
                val = [];
                return
            end
            % ---
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(dom.gid_face);
            % ---
            val = zeros(lnb_face,3);
            %--------------------------------------------------------------
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lid_face = sm.lid_face;
                gid_face = sm.gid_face;
                cWes = sm.intkit.cWe{1};
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dofe = obj.dof.value(id_edge_in_face(1:3,gid_face)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dofe = obj.dof.value(id_edge_in_face(1:4,gid_face)).';
                end
                %----------------------------------------------------------
                val(lid_face,1) = val(lid_face,2) + sum(squeeze(cWes(:,1,:)) .* dofe,2);
                val(lid_face,2) = val(lid_face,2) + sum(squeeze(cWes(:,2,:)) .* dofe,2);
                %----------------------------------------------------------
            end
            %--------------------------------------------------------------
            delete(dom);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function val = ivalue(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            if isempty(id_face)
                val = [];
                return
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
                val{i} = zeros(lnb_face,2);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_prokit;
                % ---
                lid_face = sm.lid_face;
                gid_face = sm.gid_face;
                Wx = sm.prokit.We;
                % --- same id system as submesh
                % --- same as sm.meshds.id_edge_in_elem
                id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face(:,gid_face);
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dof_ = obj.dof.value(id_edge_in_face(1:3,:)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dof_ = obj.dof.value(id_edge_in_face(1:4,:)).';
                end
                % ---
                for m = 1:nbNodeI
                    vi = zeros(length(lid_face),2);
                    for l = 1:sm.refelem.nbEd_inEl
                        wix = Wx{m}(:,1,l);
                        wiy = Wx{m}(:,2,l);
                        vi(:,1) = vi(:,1) + wix .* dof_(:,l);
                        vi(:,2) = vi(:,2) + wiy .* dof_(:,l);
                    end
                    % ---
                    val{m}(lid_face,:) = vi;
                end
            end
            %--------------------------------------------------------------
            delete(dom);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
end