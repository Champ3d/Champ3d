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

classdef NodeDofBasedScalarFaceField < ScalarFaceField
    properties
        parent_model
        dof
        reference_potential = 0
    end
    % --- Contructor
    methods
        function obj = NodeDofBasedScalarFaceField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'NodeDof')}
                args.reference_potential = 0
            end
            % ---
            obj = obj@ScalarFaceField;
            % ---
            if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                error('#parent_model and #dof must be given !');
            end
            obj <= args;
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
            val = zeros(length(id_face),1);
            [grface,lindex,face_elem_type] = f_filterface(obj.parent_model.parent_mesh.face(:,id_face));
            % ---
            for i = 1:length(grface)
                face_ = grface{i};
                elem_type = face_elem_type{i};
                if any(f_strcmpi(elem_type,{'tri','triangle'}))
                    val(lindex{i}) = mean(obj.dof.value(face_(1:3,:))).';
                elseif any(f_strcmpi(elem_type,{'quad'}))
                    val(lindex{i}) = mean(obj.dof.value(face_(1:4,:))).';
                end
            end
            % ---
            val = val + obj.reference_potential;
            % ---
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
            face_ = obj.parent_model.parent_mesh.face;
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gindex',id_face);
            % ---
            lnb_face = length(dom.gindex);
            % ---
            submesh = dom.submesh;
            % ---
            nbNodeI = submesh{1}.refelem.nbI;
            for i = 1:nbNodeI
                val{i} = zeros(lnb_face,1);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_prokit;
                % ---
                lindex = sm.lindex;
                gindex = sm.gindex;
                Wx = sm.prokit.Wn;
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dof_ = obj.dof.value(face_(1:3,gindex)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dof_ = obj.dof.value(face_(1:4,gindex)).';
                end
                % ---
                for m = 1:nbNodeI
                    vi = zeros(length(lindex),1);
                    for l = 1:sm.refelem.nbNo_inEl
                        wi = Wx{m}(:,l);
                        vi = vi + wi .* dof_(:,l);
                    end
                    % ---
                    val{m}(lindex) = vi;
                end
            end
            % ---
            for i = 1:nbNodeI
                val{i} = val{i} + obj.reference_potential;
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_face)
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
            face_ = obj.parent_model.parent_mesh.face;
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gindex',id_face);
            % ---
            lnb_face = length(dom.gindex);
            % ---
            submesh = dom.submesh;
            % ---
            nbNodeG = submesh{1}.refelem.nbG;
            for i = 1:nbNodeG
                val{i} = zeros(lnb_face,1);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex = sm.lindex;
                gindex = sm.gindex;
                Wx = sm.intkit.Wn;
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dof_ = obj.dof.value(face_(1:3,gindex)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dof_ = obj.dof.value(face_(1:4,gindex)).';
                end
                % ---
                for m = 1:nbNodeG
                    vi = zeros(length(lindex),1);
                    for l = 1:sm.refelem.nbNo_inEl
                        wi = Wx{m}(:,l);
                        vi = vi + wi .* dof_(:,l);
                    end
                    % ---
                    val{m}(lindex) = vi;
                end
            end
            % ---
            for i = 1:nbNodeG
                val{i} = val{i} + obj.reference_potential;
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
end