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
            dom = SurfaceDom('parent_mesh',obj.parent_model.parent_mesh,'gindex',id_face);
            % ---
            id_edge_in_face = obj.parent_model.parent_mesh.meshds.id_edge_in_face;
            lnb_face = length(dom.gindex);
            % ---
            val = zeros(lnb_face,2);
            %--------------------------------------------------------------
            submesh = dom.submesh;
            for k = 1:length(submesh)
                sm = submesh{k};
                sm.build_intkit;
                % ---
                lindex = sm.lindex;
                gindex = sm.gindex;
                cWes = sm.intkit.cWe{1};
                % ---
                if any(f_strcmpi(sm.elem_type,'tri'))
                    dofe = obj.dof.value(id_edge_in_face(1:3,gindex)).';
                elseif any(f_strcmpi(sm.elem_type,'quad'))
                    dofe = obj.dof.value(id_edge_in_face(1:4,gindex)).';
                end
                %----------------------------------------------------------
                val(lindex,1) = val(lindex,2) + sum(squeeze(cWes(:,1,:)) .* dofe,2);
                val(lindex,2) = val(lindex,2) + sum(squeeze(cWes(:,2,:)) .* dofe,2);
                %----------------------------------------------------------
            end
            %--------------------------------------------------------------
            delete(dom);
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function val = gvalue(obj,id_face)
            val = [];
        end
        % -----------------------------------------------------------------
    end
end