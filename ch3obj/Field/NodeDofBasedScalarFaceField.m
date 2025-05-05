%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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
        function obj = NodeDofBasedScalarFaceField()
            obj = obj@ScalarFaceField;
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
            val = zeros(1,length(id_face));
            [grface,lid_face,face_elem_type] = f_filterface(obj.parent_model.parent_mesh.face(:,id_face));
            % ---
            for i = 1:length(grface)
                face_ = grface{i};
                elem_type = face_elem_type{i};
                if any(f_strcmpi(elem_type,{'tri','triangle'}))
                    val(1,lid_face{i}) = mean(obj.dof.value(face_(1:3,:)));
                elseif any(f_strcmpi(elem_type,{'quad'}))
                    val(1,lid_face{i}) = mean(obj.dof.value(face_(1:4,:)));
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
            face_ = obj.parent_model.parent_mesh.face;
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            lnb_face = length(dom.gid_face);
            % ---
            submesh = dom.submesh;
            % ---
            nbNodeI = submesh{1}.refelem.nbI;
            for i = 1:nbNodeI
                val{i} = zeros(1,lnb_face);
            end
            % ---
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_prokit;
                % ---
                lid_face = sm.lid_face;
                gid_face = sm.gid_face;
                Wx = sm.prokit.Wn;
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dof_ = obj.dof.value(face_(1:3,gid_face)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dof_ = obj.dof.value(face_(1:4,gid_face)).';
                end
                % ---
                for m = 1:nbNodeI
                    vi = zeros(length(lid_face),1);
                    for l = 1:sm.refelem.nbNo_inEl
                        wi = Wx{m}(:,l);
                        vi = vi + wi .* dof_(:,l);
                    end
                    % ---
                    val{m}(1,lid_face) = vi.';
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_face)
            % --- XTODO
        end
        % -----------------------------------------------------------------
    end
end