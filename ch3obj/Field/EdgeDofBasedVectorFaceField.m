%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef EdgeDofBasedVectorFaceField < VectorFaceField
    properties
        parent_model
        dof
    end
    % properties (Dependent)
    %     cvalue
    %     cnode
    %     ivalue
    %     inode
    %     gvalue
    %     gnode
    % end
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
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(dom.gid_face);
            % ---
            val = zeros(2,lnb_face);
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
                val(1,lid_face) = val(1,lid_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
                val(2,lid_face) = val(2,lid_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
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
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gid_face',id_face);
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(dom.gid_face);
            % ---
            val = zeros(2,lnb_face);
            vector_field = cell(nbG,1);
            for i = 1:nbG
                vector_field{i} = sparse(3,nb_elem);
            end
            
            nbG = obj.refelem.nbI;
                    % ---
                    Wx = cell(1,nbG);
                    for iG = 1:nbG
                        Wx{iG} = obj.prokit.We{iG}(id_elem,:,:);
                    end
            end
            %--------------------------------------------------------------
            



            %--------------------------------------------------------------
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_prokit;
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
                val(1,lid_face) = val(1,lid_face) + sum(squeeze(cWes(:,1,:)) .* dofe,2).';
                val(2,lid_face) = val(2,lid_face) + sum(squeeze(cWes(:,2,:)) .* dofe,2).';
                %----------------------------------------------------------
            end
            %--------------------------------------------------------------
            delete(dom);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end
end