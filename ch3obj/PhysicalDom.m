%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

classdef PhysicalDom < Xhandle
    properties
        parent_model
        id_dom2d
        id_dom3d
        % ---
        dom
        % ---
        matrix
        tarray
        % ---
        % 'by_coordinates', 'by_id_dom'[by default]
        parameter_dependency_search = 'by_id_dom'
    end
    properties (Dependent)
        gindex
    end
    % --- Contructor
    methods
        function obj = PhysicalDom()
            % ---
            obj@Xhandle;
            % ---
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = get.gindex(obj)
            val = obj.dom.gindex;
        end
        % -----------------------------------------------------------------
    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function set_parameter(obj)
            % --- XTODO
            % should put list in config file ?
            paramlist = {'sigma','mur','bs','br','r_ht','r_et',...
                         'Is','Vs','Js',...
                         'rho','cp','lambda','h','ps','pv', ...
                         'speed'};
            % ---
            for i = 1:length(paramlist)
                param = paramlist{i};
                if isprop(obj,param)
                    if isnumeric(obj.(param))
                        if ~isempty(obj.(param))
                            % ---------------------------------------------
                            const = obj.(param);
                            if numel(const) == 1
                                obj.(param) = ScalarParameter('parent_model',obj.parent_model,'f',obj.(param));
                            elseif numel(const) == 2 || numel(const) == 3
                                obj.(param) = VectorParameter('parent_model',obj.parent_model,'f',obj.(param));
                            elseif isequal(size(const),[2 2]) || isequal(size(const),[3 3])
                                obj.(param) = TensorParameter('parent_model',obj.parent_model,'f',obj.(param));
                            else
                                fprintf(['Constant parameter must be a single scalar, ' ...
                                         'single vector or single tensor !\n' ...
                                         'Consider ScalarParameter, VectorParameter, TensorParameter, ' ...
                                         'LTensor or LVector ' ...
                                         'for general purpose. \n']);
                                error('Constant parameter error');
                            end
                            % ---------------------------------------------
                        end
                    elseif isa(obj.(param),'Parameter')
                        if ~isempty(obj.(param).parent_model)
                            if ~isequal(obj.(param).parent_model,obj.parent_model)
                                fprintf('#parameter parent_model must be equal to physical dom parent_model \n');
                                error('Parameter error');
                            end
                        else
                            f_fprintf(1,'/!\\',0,'#parent_model of parameter unspecified --> use the same as physical dom \n');
                            obj.(param).parent_model = obj.parent_model;
                        end
                    end
                end
            end
        end
        % -----------------------------------------------------------------
        function get_geodom(obj)
            if isempty(obj.parent_model)
                return
            end
            if isempty(obj.parent_model.parent_mesh)
                return
            end
            % ---
            id_dom_ = [];
            % ---
            if ~isempty(obj.id_dom3d)
                id_dom_ = f_to_scellargin(obj.id_dom3d);
            elseif ~isempty(obj.id_dom2d)
                id_dom_ = f_to_scellargin(obj.id_dom2d);
            end
            % ---
            if isempty(id_dom_)
                return
            end
            % ---
            obj.dom = obj.parent_model.parent_mesh.dom.(id_dom_{1});
            % ---
            % --- can define on multiple geo doms
            % --- but better if define dom in mesh
            % for i = 2:length(id_dom_)
            %     obj.dom = obj.dom + obj.parent_model.parent_mesh.dom.(id_dom_{i});
            % end
        end
        % -----------------------------------------------------------------
    end
    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ----------------------------------------------------
            submesh_ = obj.dom.submesh;
            for i = 1:length(submesh_)
                % ---
                submesh_{i}.node = obj.parent_model.moving_frame.movenode(submesh_{i}.node);
                % ---
                argu = f_to_namedarg(args,'with_out','id');
                submesh_{i}.plot(argu{:}); hold on
                % ---
                celem = submesh_{i}.cal_celem;
                dim   = size(celem,1);
                id = replace(obj.id,'_','-');
                if dim == 2
                    [~, imax] = max(celem(2,:));
                    celem = celem(:,imax);
                    t = text(celem(1),celem(2),['<-----' id]);
                    t.FontWeight = 'bold';
                elseif dim == 3
                    [~, imax] = max(celem(3,:));
                    celem = celem(:,imax);
                    t = text(celem(1),celem(2),celem(3),['<-----' id]);
                    t.FontWeight = 'bold';
                end
            end
            % ----------------------------------------------------
            %argu = f_to_namedarg(args);
            %obj.dom.plot(argu{:});
            % ---
        end
        % -----------------------------------------------------------------
        function plotjv(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            obj.plotvectorfield('show_dom',args.show_dom,'field_name','jv')
        end
        % -----------------------------------------------------------------
        function plotev(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            obj.plotvectorfield('show_dom',args.show_dom,'field_name','ev')
        end
        % -----------------------------------------------------------------
        function plotbv(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            obj.plotvectorfield('show_dom',args.show_dom,'field_name','bv')
        end
        % -----------------------------------------------------------------
        function plotjs(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none');
                hold on
            end
            % ---
            sdom = obj.dom;
            if isa(sdom,'SurfaceDom3d')
                id_face = sdom.gindex;
                face = obj.parent_model.parent_mesh.face(:,id_face);
                node = obj.parent_model.parent_mesh.node;
                js   = obj.parent_model.field.js(:,id_face);
                js   = f_magnitude(js);
                %--------------------------------------------------------------
                clear msh;
                %--------------------------------------------------------------
                msh.Vertices  = node.';
                msh.FaceColor = 'none';
                msh.EdgeColor = 'none'; % [0.7 0.7 0.7] --> gray
                %--------------------------------------------------------------
                % ---
                if size(face,1) == 4
                    id_tria = find(face(4,:) == 0);
                elseif size(face,1) == 3
                    id_tria = 1:nb_face;
                end
                % ---
                id_quad = setdiff(1:length(js),id_tria);
                % ---
                if ~isempty(id_tria)
                    msh.Faces = (face(1:3,id_tria)).';
                    msh.FaceVertexCData = f_tocolv(full(js(itria)));
                    msh.FaceColor = 'flat';
                    patch(msh); hold on
                end
                % ---
                if ~isempty(id_quad)
                    msh.Faces = (face(1:4,id_quad)).';
                    msh.FaceVertexCData = f_tocolv(full(js(id_quad)));
                    msh.FaceColor = 'flat';
                    patch(msh); hold on
                end
                % ---
                axis equal; axis tight; view(3); hold on
                %--------------------------------------------------------------
                f_chlogo;
            end
        end
        % -----------------------------------------------------------------
        function plotT(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            it = obj.parent_model.ltime.it;
            obj.parent_model.field{it}.T.node.plot('meshdom_obj',obj.dom,...
                'show_dom',args.show_dom);
            % ---
        end
        % -----------------------------------------------------------------
        function plotps(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            obj.plotscalarfield('show_dom',args.show_dom,'field_name','ps')
        end
        % -----------------------------------------------------------------
        function plotpv(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            obj.plotscalarfield('show_dom',args.show_dom,'field_name','pv')
        end
        % -----------------------------------------------------------------
        
    end

    % --- Methods
    methods (Hidden)
        % -----------------------------------------------------------------
        function plotvectorfield(obj,args)
            arguments
                obj
                args.show_dom = 1
                args.field_name = []
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            if isa(obj.dom,'VolumeDom3d')
                id_elem = obj.dom.gindex;
                fv = obj.parent_model.field.(args.field_name)(:,id_elem);
                no = obj.parent_model.parent_mesh.celem(:,id_elem);
                if isreal(fv)
                    f_quiver(no,fv);
                else
                    subplot(121);
                    f_quiver(no,real(fv)); title('Real part')
                    subplot(122);
                    f_quiver(no,imag(fv)); title('Imag part')
                end
            end
        end
        % -----------------------------------------------------------------
        function plotscalarfield(obj,args)
            arguments
                obj
                args.show_dom = 1
                args.field_name = []
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % --- for ScalarElemField
            if any(f_strcmpi(args.field_name,{'pv'}))
                fs = obj.parent_model.field.(args.field_name);
                % ---
                gindex_ = obj.dom.gindex;
                celem = obj.parent_model.parent_mesh.celem(:,gindex_);
                % ---
                scatter3(celem(1,:),celem(2,:),celem(3,:),[],fs(gindex_));
                f_colormap;
                return
            end
            % --- for ScalarNodeField
            if isa(obj.dom,'VolumeDom3d')
                node = obj.parent_model.parent_mesh.node;
                elem = obj.parent_model.parent_mesh.elem(:,obj.dom.gindex);
                elem_type = f_elemtype(elem);
                face = f_boundface(elem,node,'elem_type',elem_type);
                % ---
                it = obj.parent_model.ltime.it;
                fs = obj.parent_model.field{it}.(args.field_name).node.value;
                % ---
                f_patch(node,face,'defined_on','face','scalar_field',fs);
            end
            % ---
            if isa(obj.dom,'SurfaceDom3d')
                node = obj.parent_model.parent_mesh.node;
                face = obj.parent_model.parent_mesh.face(:,obj.dom.gindex);
                % ---
                it = obj.parent_model.ltime.it;
                fs = obj.parent_model.field{it}.(args.field_name).node.value;
                %fs = fs(obj.dom.gindex);
                % ---
                f_patch(node,face,'defined_on','face','scalar_field',fs);
            end
        end
    end
end